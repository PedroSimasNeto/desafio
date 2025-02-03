resource "aws_glue_catalog_database" "data_lake_database" {
  name = var.datalake_database

  description = "Catálogo de dados para o Data Lake"
}

resource "aws_glue_catalog_table" "data_lake_table" {
  database_name = aws_glue_catalog_database.data_lake_database.name
  name          = var.datalake_tabela

  table_type = "EXTERNAL_TABLE" # Tipo de tabela externa para o Lake Formation

  storage_descriptor {
    columns {
      name = "timestamp"
      type = "STRING"
    }

    columns {
      name = "sending_address"
      type = "STRING"
    }

    columns {
      name = "receiving_address"
      type = "STRING"
    }

    columns {
      name = "amount"
      type = "STRING"
    }

    columns {
      name = "transaction_type"
      type = "STRING"
    }

    columns {
      name = "location_region"
      type = "STRING"
    }

    columns {
      name = "ip_prefix"
      type = "STRING"
    }

    columns {
      name = "login_frequency"
      type = "STRING"
    }

    columns {
      name = "session_duration"
      type = "STRING"
    }

    columns {
      name = "purchase_pattern"
      type = "STRING"
    }

    columns {
      name = "age_group"
      type = "STRING"
    }

    columns {
      name = "risk_score"
      type = "STRING"
    }

    columns {
      name = "anomaly"
      type = "STRING"
    }

    location      = "s3://${aws_s3_bucket.data_lake_bucket.bucket}/data/" # Localização no S3 para armazenar os dados
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
      parameters = {
        "serialization.format" = "1"
      }
    }
  }

  partition_keys {
    name = "anomesdia"
    type = "STRING"
  }
}

resource "aws_glue_crawler" "data_lake_crawler" {
  name          = "data-lake-crawler"
  role          = aws_iam_role.lakeformation_glue_role.arn
  database_name = aws_glue_catalog_database.data_lake_database.name

  s3_target {
    path = "s3://${aws_s3_bucket.data_lake_bucket.bucket}"
  }

  configuration = jsonencode({
    "Version" : 1.0,
    "CrawlerOutput" : {
      "Partitions" : {
        "AddOrUpdateBehavior" : "InheritFromTable"
      }
    }
  })

  tags = {
    Name        = "DataLakeCrawler"
    Environment = "Production"
  }
}
