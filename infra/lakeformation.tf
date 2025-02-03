resource "aws_lakeformation_data_lake_settings" "lakeformation_data_lake_settings" {
  admins = [data.aws_iam_session_context.current.issuer_arn]
}

resource "aws_iam_role" "lakeformation_glue_role" {
  name = "LakeFormationGlueRole"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "glue.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lakeformation.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "LakeFormationGlueRole"
    Environment = "Production"
  }
}

resource "aws_iam_policy" "lakeformation_glue_policy" {
  name        = "LakeFormationGluePolicy"
  description = "Permissões para Glue e LakeFormation acessar S3 e demais recursos"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        "Resource" : [
          aws_s3_bucket.data_lake_bucket.arn,
          "${aws_s3_bucket.data_lake_bucket.arn}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "glue:*",
          "lakeformation:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_lakeformation_resource" "s3_data_location" {
  arn = aws_s3_bucket.data_lake_bucket.arn
}

resource "aws_iam_role_policy_attachment" "lakeformation_glue_policy_attach" {
  role       = aws_iam_role.lakeformation_glue_role.name
  policy_arn = aws_iam_policy.lakeformation_glue_policy.arn
}

# resource "aws_lakeformation_permissions" "lakeformation_permissions" {
#   principal = aws_iam_role.lakeformation_glue_role.arn
#   permissions = ["DATA_LOCATION_ACCESS"]

#   data_location {
#     arn = aws_lakeformation_resource.s3_data_location.arn
#   }
# }
