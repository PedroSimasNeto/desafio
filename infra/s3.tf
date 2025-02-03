resource "aws_s3_bucket" "s3_recebimento_arquivo_desafio" {
  bucket = var.bucket_recebimento

  tags = {
    Name        = "s3-recebimento-arquivo-desafio"
    Environment = "Desafio"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_recebimento_arquivo_desafio_access" {
  bucket = aws_s3_bucket.s3_recebimento_arquivo_desafio.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_recebimento_arquivo_desafio_lifecycle" {
  bucket = aws_s3_bucket.s3_recebimento_arquivo_desafio.id

  rule {
    id     = "cleanup_old_files"
    status = "Enabled"

    expiration {
      days = 5
    }

    noncurrent_version_expiration {
      noncurrent_days = 5
    }
  }
}

resource "aws_s3_bucket" "data_lake_bucket" {
  bucket = var.s3_datalake_bucket

  tags = {
    Name        = "DataLakeBucket"
    Environment = "Production"
  }
}


resource "aws_s3_bucket_public_access_block" "data_lake_bucket_access" {
  bucket = aws_s3_bucket.data_lake_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "data_lake_bucket_lifecycle" {
  bucket = aws_s3_bucket.data_lake_bucket.id

  rule {
    id     = "cleanup_old_files"
    status = "Enabled"

    expiration {
      days = 30
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}


resource "aws_s3_bucket" "script_desafio" {
  bucket = "s3-script-desafio"

  tags = {
    Name        = "ScriptDesafio"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_public_access_block" "script_desafio_access" {
  bucket = aws_s3_bucket.script_desafio.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
