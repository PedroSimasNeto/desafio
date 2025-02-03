resource "aws_cloudwatch_log_group" "cloudwatch_glue_log_group" {
  name              = "cloudwatch_glue_log_group"
  retention_in_days = 14
}