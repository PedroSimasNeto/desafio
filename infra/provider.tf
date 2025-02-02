provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-backend-desafio"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
