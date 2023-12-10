data "terraform_remote_state" "s3" {
  backend = "s3"
  config = {
    bucket = "stamzid-tfstate"
    key    = "s3/${var.tenant}-${var.environment}-${var.stage}/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "athena" {
  backend = "s3"
  config = {
    bucket = "stamzid-tfstate"
    key    = "athena/${var.tenant}-${var.environment}-${var.stage}/terraform.tfstate"
    region = var.region
  }
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "athena_role" {
  name = "${var.tenant}-${var.environment}-${var.stage}-athena-query-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "athena.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "athena_role_policy" {
  role = aws_iam_role.athena_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "athena:GetWorkGroup",
          "athena:StopQueryExecution"
        ],
        Resource = [
          data.terraform_remote_state.athena.outputs.athena_workgroup_arn
        ],
        Effect = "Allow"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${data.terraform_remote_state.s3.outputs.superset_data_bucket_id}",
          "arn:aws:s3:::${data.terraform_remote_state.s3.outputs.superset_data_bucket_id}/*",
          "arn:aws:s3:::${data.terraform_remote_state.s3.outputs.athena_output_bucket_id}",
          "arn:aws:s3:::${data.terraform_remote_state.s3.outputs.athena_output_bucket_id}/*"
        ],
        Effect = "Allow"
      }
    ]
  })
}
