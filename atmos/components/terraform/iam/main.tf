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
      },
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
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

resource "aws_iam_user" "athena_user" {
  name = "${var.tenant}-${var.environment}-${var.stage}-athena-user"
}

resource "aws_iam_access_key" "athena_user_key" {
  user = aws_iam_user.athena_user.name
}

resource "aws_iam_user_policy" "athena_user_policy" {
  name = "AthenaUserRoleAssumptionPolicy"
  user = aws_iam_user.athena_user.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Resource = aws_iam_role.athena_role.arn
      }
    ]
  })
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.tenant}-${var.environment}-${var.stage}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.tenant}-${var.environment}-${var.stage}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "ecs_task_s3_policy" {
  name        = "${var.tenant}-${var.environment}-${var.stage}-ecs-execution-role-policy"
  description = "ECS task policy to access specific S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = [
          "arn:aws:s3:::${data.terraform_remote_state.s3.outputs.superset_data_bucket_id}",
          "arn:aws:s3:::${data.terraform_remote_state.s3.outputs.athena_output_bucket_id}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_s3_policy.arn
}
