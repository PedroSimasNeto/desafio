import json
import boto3

def handler(event, context):
    glue = boto3.client('glue')

    # Nome do workflow que será acionado
    workflow_name = 'workflow-desafio'
    
    try:
        response = glue.start_workflow_run(Name=workflow_name)
        print(f"Workflow {workflow_name} iniciado com sucesso: {response}")
    except Exception as e:
        print(f"Erro ao iniciar o workflow: {str(e)}")
