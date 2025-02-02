variable "aws_region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "bucket_recebimento" {
  description = "Nome que será utilizado para o bucket que receberá o arquivo CSV"
}
