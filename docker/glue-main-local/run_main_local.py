import argparse
import logging
from pathlib import Path
import sys

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, current_date, date_format, lit

# Adiciona o caminho do app/glue para importar os modulos de qualidade de dados
sys.path.append("/opt/project/app/glue")
from utils.quality.data_quality.DataQuality import DataQuality
from utils.quality.utils.utils import create_df_from_dq_results


logging.basicConfig(
    format="%(levelname)s: %(asctime)s - %(message)s",
    level=logging.INFO,
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("ETL Desafio Local")


def parse_args():
    """
    Tratativa para que seja possivel rodar o Glue main localmente em um container Docker, passando os parametros de entrada e saida"""
    parser = argparse.ArgumentParser(description="Executa o Glue main localmente em Docker")
    parser.add_argument("--input-path", required=True, help="Arquivo CSV de entrada")
    parser.add_argument(
        "--output-path",
        default="/opt/project/output/desafio",
        help="Diretorio de saida parquet",
    )
    parser.add_argument(
        "--dq-config",
        default="/opt/project/app/glue/utils/quality/config/config.json",
        help="Arquivo de configuracao de data quality",
    )
    return parser.parse_args()


def build_spark_session() -> SparkSession:
    return (
        SparkSession.builder.appName("etl-desafio-local")
        .config("spark.serializer", "org.apache.spark.serializer.KryoSerializer")
        .config("spark.sql.sources.partitionOverwriteMode", "dynamic")
        .enableHiveSupport()
        .getOrCreate()
    )


def main():
    args = parse_args()

    if not Path(args.dq_config).exists():
        raise FileNotFoundError(f"Arquivo de DQ nao encontrado: {args.dq_config}")

    spark = build_spark_session()

    logger.info("Iniciando ETL local")
    logger.info("Lendo CSV de entrada")
    dataframe = (
        spark.read.format("csv")
        .options(header="true", sep=",")
        .load(args.input_path)
    )

    dataframe = dataframe.select(
        col("timestamp").cast("string"),
        col("sending_address").cast("string"),
        col("receiving_address").cast("string"),
        col("amount").cast("double"),
        col("transaction_type").cast("string"),
        col("location_region").cast("string"),
        col("ip_prefix").cast("string"),
        col("login_frequency").cast("int"),
        col("session_duration").cast("double"),
        col("purchase_pattern").cast("string"),
        col("age_group").cast("string"),
        col("risk_score").cast("double"),
        col("anomaly").cast("string"),
    )

    dataframe = dataframe.withColumn("anomesdia", lit(date_format(current_date(), "yyyyMMdd")))

    logger.info("Executando Data Quality")
    dq = DataQuality(dataframe, args.dq_config)
    dq_results = dq.run_test()
    dq_df = create_df_from_dq_results(spark, dq_results)
    dq_df.show(truncate=False)

    logger.info(f"Escrevendo resultado em {args.output_path}")
    (
        dataframe.coalesce(1).write.mode("overwrite")
        .partitionBy("anomesdia")
        .parquet(args.output_path)
    )

    logger.info("Finalizado com sucesso")
    spark.stop()


if __name__ == "__main__":
    main()
