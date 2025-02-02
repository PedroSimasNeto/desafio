resource "aws_glue_catalog_database" "data_lake_database" {
  name = "data_lake_database"

  description = "Catálogo de dados para o Data Lake"
}

resource "aws_glue_catalog_table" "data_lake_table" {
  database_name = aws_glue_catalog_database.data_lake_database.name
  name          = "data_lake_table"

  table_type = "EXTERNAL_TABLE" # Tipo de tabela externa para o Lake Formation

  storage_descriptor {
    columns {
      name = "id"
      type = "string"
    }
    columns {
      name = "nome"
      type = "string"
    }

    location      = "s3://${aws_s3_bucket.data_lake_bucket.bucket}/data/" # Localização no S3 para armazenar os dados
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
  }

  partition_keys {
    name = "anomesdia"
    type = "string"
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
