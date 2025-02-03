import os
import json
import boto3
import io

# Configurações da S3
s3 = boto3.client('s3')
BUCKET_NAME = 'seu-bucket-s3'

# Configurações do Google Drive

def download_from_google_drive(file_id, credentials):
    """Baixa um arquivo do Google Drive usando o ID e retorna os bytes."""


def upload_to_s3(file_data, bucket_name, s3_key):
    """Faz upload dos dados para o S3."""
    s3.upload_fileobj(file_data, bucket_name, s3_key)
    print(f"Arquivo carregado para S3: {s3_key}")

def lambda_handler(event, context):
    
    try:
        # Baixar o arquivo do Google Drive
        file_data = download_from_google_drive("", "")
        
        # Nome do arquivo no S3
        s3_key = 'caminho/arquivo_google_drive.ext'

        # Upload para o S3
        upload_to_s3(file_data, BUCKET_NAME, s3_key)
        
        return {
            'statusCode': 200,
            'body': json.dumps(f"Arquivo {s3_key} salvo com sucesso no S3!")
        }
    except Exception as e:
        print(f"Erro: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Falha ao salvar arquivo no S3: {str(e)}")
        }
