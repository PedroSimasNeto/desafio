import sys
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.job import Job
from utils import SparkUtils
from utils.spark_catalog import SparkCatalog
from pyspark.sql import DataFrame
from pyspark.sql.functions import col, row_number
import logging
from pyspark.sql import Window

params = [
    "JOB_NAME",
    "BUCKET_RECEBIMENTO",
    "DATABASE",
    "TABELA",
]

logging.basicConfig(
    format="%(levelname)s: %(asctime)s - %(message)s",
    level=logging.INFO,
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("ETL Desafio")

class etl_desafio:
    def __init__(self):
        self.spark = SparkUtils.get_spark()
        self.args = getResolvedOptions(sys.argv, params)
        self.glueContext = GlueContext(self.spark.engine.spark_session.sparkContext)
        self.job = Job(self.glueContext)

    def read_csv(self, path) -> DataFrame:
        return self.spark.get_filesystem_connector(path, "csv", {"header": "true", "sep": ","})

    def write_table(self, dataframe, database, tabela):
        SparkCatalog.put_df_to_table(dataframe, database, tabela)

    def run(self):
        try:
            self.job.init(self.args['JOB_NAME'], self.args)
            logger.info("Iniciando ETL Desafio")

            bucket_recebimento = self.args["BUCKET_RECEBIMENTO"]
            database = self.args["DATABASE"]
            tabela = self.args["TABELA"]

            logger.info(f"Leitura do arquivo")
            dataframe = self.read_csv(bucket_recebimento)

            dataframe = dataframe.select(
                col("timestamp").cast("string"),
                col("sending_address").cast("string"),
                col("receiving_address").cast("string"),
                col("amount").cast("string"),
                col("transaction_type").cast("string"),
                col("location_region").cast("string"),
                col("ip_prefix").cast("string"),
                col("login_frequency").cast("string"),
                col("session_duration").cast("string"),
                col("purchase_pattern").cast("string"),
                col("age_group").cast("string"),
                col("risk_score").cast("string"),
                col("anomaly").cast("string")
            )

            # Filtrar apenas transações do tipo "sale"
            sales_df = dataframe.filter(col("transaction_type") == "sale")

            # Criar uma janela particionada por "receiving_address" e ordenada por "timestamp" (decrescente)
            window_spec = Window.partitionBy("receiving_address").orderBy(col("timestamp").desc())

            # Adicionar uma coluna com o número da linha para identificar a transação mais recente por "receiving_address"
            sales_with_row_number = sales_df.withColumn("row_num", row_number().over(window_spec))

            # Filtrar para pegar apenas a transação mais recente para cada "receiving_address" (row_num = 1)
            recent_sales = sales_with_row_number.filter(col("row_num") == 1)

            # Ordenar pelo valor de "amount" em ordem decrescente e pegar os 3 maiores valores
            top_3_recent_sales = recent_sales.orderBy(col("amount").desc()).limit(3)

            # Selecionar as colunas "receiving_address", "amount" e "timestamp"
            result = top_3_recent_sales.select("receiving_address", "amount", "timestamp")
            
            logger.info(f"Escrevendo tabela {database}.{tabela}")
            self.write_table(result, database, tabela)

            self.job.commit()
        except Exception as e:
            logger.error(f"Erro ao executar ETL Desafio: {e}")
            raise e
