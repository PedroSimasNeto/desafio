from typing import Dict, Optional
import json
from utils.spark_engine import SparkEngine
from pyspark.sql import DataFrame, SparkSession
from pyspark.sql.functions import lit
import boto3

class SparkCatalog():
    def __init__(
        self, engine: SparkEngine
    ) -> None:
        self.__engine = engine

    def put_df_to_table(
        self,
        dataframe: DataFrame,
        database: str,
        table: str,
        write_mode: str = "overwrite",
        format: str = "parquet",
        compression: str = "snappy",
        repartition: Optional[int] = None,
    ) -> None:
        if repartition:
            files_quantity = repartition
        else:
            files_quantity = self.calculate_file_quantify(
                dataframe=dataframe, format=format, compression=compression
            )
        
        spark_session: SparkSession = self.__engine.spark_session
        glue_client = boto3.client("glue", region_name="us-east-1")

        # metadata = spark_session.read.table(f"{database}.{table}")
        # metadata = spark_session.catalog.listColumns(database, table)
        metadata = glue_client.get_table(DatabaseName=database, Name=table)["Table"]["StorageDescriptor"]["Columns"]

        catalog_columns = [column["Name"].lower() for column in metadata]
        dataframe_columns = [column.lower() for column in dataframe.columns]
        diff_columns = set(dataframe_columns) - set(catalog_columns)

        formatted_df = dataframe
        for column in diff_columns:
            formatted_df = formatted_df.withColumn(column, lit(None))
        formatted_df.select(catalog_columns).repartition(
            files_quantity
        ).write.mode(write_mode).insertInto(f"{database}.{table}")

    def calculate_compression(
        self,
        tam_df: float,
        format: str,
        compression: str
    ) -> float:
        
        # Dicionario com os fomartos de arquivo
        dict_format: Dict[str, float] = {
            "parquet": 0.2, # ~80% de compressão
            "csv": 0.3, # ~70% de compressão
            "avro": 0.1, # ~90% de compressão
            "josn": 0.8, # ~20% de compressão
        }

        format_com_rate: float = dict_format.get(format.lower(), 1.0)
        size_df_comp_for: float = tam_df * format_com_rate

        # Dicionário com os fatores de compressão para cada tipo suportado
        dict_compactator: Dict[str, float] = {
            "None": 1, # Sem compressão
            "snappy": 0.4, # ~60% de compressão
            "gzip": 0.3 # ~70% de compressão
        }

        compact_comp_rate: float = dict_compactator.get(
            compression.lower(), 1.0
        )
        size_df_comp_com: float = size_df_comp_for * compact_comp_rate

        return size_df_comp_com

    def calculate_file_quantity(
        self,
        dataframe: DataFrame,
        format: str,
        compression: str,
        block_size: int = 256,
    ):
        # Obtem quantidade de registros do DF
        rows_quantity: int = dataframe.count()

        # Obtem o tomanho da primeira linha p/ usar como parametro de cálculo
        avg_row_size: int = len(json.dumps(
            dataframe.first().asDict(), default=str))

        # Obtem o tamanho medio do DataFrame em bytes
        size_df_bytes: int = rows_quantity * avg_row_size
        # Converte o tamanho médio do DF para megabytes
        size_df_mb: float = size_df_bytes / (1024 * 1024)

        if size_df_mb <= block_size:
            files_quantity: int = 1
        else:
            size_df_comp = self.calculate_compression(
                tam_df=size_df_mb, format=format, compression=compression
            )
            files_quantity = int(size_df_comp / block_size)
            if files_quantity <= 0:
                files_quantity: int = 1
        return files_quantity
