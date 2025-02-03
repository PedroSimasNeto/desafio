from typing import Any, Dict, Optional
from utils.spark_connector import SparkConnector

class SparkUtils:

    @staticmethod
    def get_spark(config: Optional[Dict[str, Any]] = None) -> SparkConnector:
        return SparkConnector(config=config)