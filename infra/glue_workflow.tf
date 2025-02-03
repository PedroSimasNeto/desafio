resource "aws_glue_workflow" "workflow_desafio" {
  name = "workflow-desafio"
  
}

resource "aws_glue_trigger" "workflow_trigger" {
  name               = "trigger-start"
  type               = "ON_DEMAND"
  workflow_name      = aws_glue_workflow.workflow_desafio.name

  actions {
    job_name = aws_glue_job.glue_job.name
  }
}