resource "aws_glue_job" "glue_job" {
  name     = var.job_name
  role_arn = aws_iam_role.glue_role.arn
  # max_retries       = 1
  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 2

  command {
    name            = "glueetl"
    script_location = "s3://${var.s3_bucket}/main.py"
    python_version  = "3"
  }

  default_arguments = {
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"                   = ""
    "--job-bookmark-option"              = "job-bookmark-disable"
    "--TempDir"                          = "s3://${var.s3_bucket}/tmp/"
    "--job-language"                     = "python"
    "--job-language-version"             = "3"
    "--bucket-recebimento"               = "s3://${var.bucket_recebimento}"
    "--database"                         = var.datalake_database
    "--tabela"                           = var.datalake_tabela
    "--extra-py-files"                   = "s3://${var.s3_bucket}/utils.zip"
    "--enable-glue-datacatalog"          = "true"
    "--additional-python-modules"        = "great-expectations==0.17.7,urllib3==1.26.20"
  }

  execution_property {
    max_concurrent_runs = 1
  }
}

resource "aws_iam_role" "glue_role" {
  name = "glue-job-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "glue_policy" {
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "iam:PassRole",
        Resource = "arn:aws:iam::533413897283:role/glue-job-role"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::${var.bucket_recebimento}",
          "arn:aws:s3:::${var.bucket_recebimento}/*",
          "arn:aws:s3:::${var.s3_datalake_bucket}",
          "arn:aws:s3:::${var.s3_datalake_bucket}/*",
          "arn:aws:s3:::${var.s3_bucket}",
          "arn:aws:s3:::${var.s3_bucket}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:AssociateKmsKey",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "cloudwatch:PutMetricData"
        ],
        "Resource" : "*"
      },
      {
        Effect = "Allow",
        Action = [
          "lakeformation:*",
          "glue:*",
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
        ],
        Resource = "*"
      }
    ]
  })
}
