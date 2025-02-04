import sys
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.job import Job
from utils import SparkUtils
from utils.spark_catalog import SparkCatalog
from pyspark.sql import DataFrame
from pyspark.sql.functions import col, avg
import logging

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

            # Calcular a média de "risk_score" por "location_region"
            avg_risk_score_by_region = dataframe.groupBy("location_region").agg(avg("risk_score").alias("avg_risk_score"))

            # Ordenar em ordem decrescente pela média de "risk_score"
            result = avg_risk_score_by_region.orderBy(col("avg_risk_score").desc())

            logger.info(f"Escrevendo tabela {database}.{tabela}")
            self.write_table(result, database, tabela)

            self.job.commit()
        except Exception as e:
            logger.error(f"Erro ao executar ETL Desafio: {e}")
            raise e
