variable "aws_region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "bucket_recebimento" {
  description = "Nome que será utilizado para o bucket que receberá o arquivo CSV"
}

variable "job_name" {
  description = "Nome do Glue Job"
  type        = string
  default     = "glue-job-script-desafio"
}

variable "s3_bucket" {
  description = "Nome do bucket S3 que contém o script"
  type        = string
  default     = "s3-script-desafio"
}

variable "s3_datalake_bucket" {
  description = "Nome do bucket S3 do Data Lake"
  type        = string
  default     = "datalake-bucket-desafio" 
}

variable "glue_role" {
  description = "ARN da role do Glue"
  type        = string
}

variable "datalake_database" {
  description = "Nome do banco de dados do Data Lake"
  type        = string  
}

variable "datalake_tabela" {
  description = "Nome da tabela do Data Lake"
  type        = string  
}