from typing import Any, Dict, Optional
from utils.spark_engine import SparkEngine
from pyspark.sql import SparkSession, DataFrame

class SparkConnector:

    def __init__(self, config: Optional[Dict[str, Any]] = None) -> None:
        self.engine = SparkEngine(config)

    def get_filesystem_connector(
        self,
        path: str,
        file_format: str,
        options: Optional[Dict[str, Any]] = {},
    ) -> DataFrame:
        spark: SparkSession = self.engine.spark_session
        return spark.read.format(file_format).options(options).load(path)