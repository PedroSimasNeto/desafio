from typing import Any, Optional, Dict
from pyspark.sql import SparkSession
from pyspark import SparkConf

class SparkEngine:
    def __new__(cls, config):
        if not hasattr(cls, "instance"):
            cls.instance = super(SparkEngine, cls).__new__(cls)
        return cls.instance
    
    def __init__(self, config: Optional[Dict[str, Any]] = None) -> None:
        """
        Esta classe cria os objetos de conexão do Spark. Que podem ser acessados nos próprios atributos da classe instanciada.

        Parameters
        ----------
        config : dict, optional
            Dicionário com as configurações do Spark onde cada chave deve
            inidicar o nome da configurtação a ser alterada seguida do respectivo
            valor a ser setado.
        """
        self.spark_config = SparkConf()
        self.default_config = {
            "spark.serializer": "org.apache.spark.serializer.KryoSerializer",
            "spark.sql.sources.partitionOverwriteMode": "dynamic",
            "hive.exec.dynamic.partition": "true",
            "hive.exec.dynamic.partition.mode": "nonstrict",
        }

        if config:
            self.default_config.update(config)
        for key, value in self.default_config.items():
            self.spark_config.set(key, value)

        self.spark_session = SparkSession.builder.config(conf=self.spark_config).enableHiveSupport().getOrCreate()
