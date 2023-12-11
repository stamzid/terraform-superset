data "terraform_remote_state" "s3" {
  backend = "s3"
  config = {
    bucket = "stamzid-tfstate"
    key    = "s3/${var.tenant}-${var.environment}-${var.stage}/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "stamzid-tfstate"
    key    = "vpc/${var.tenant}-${var.environment}-${var.stage}/terraform.tfstate"
    region = var.region
  }
}

resource "aws_athena_database" "superset_database" {
  name   = "${var.tenant}_${var.environment}_${var.stage}_superset_db"
  bucket = data.terraform_remote_state.s3.outputs.athena_output_bucket_id

  encryption_configuration {
    encryption_option = "SSE_KMS"
    kms_key           = data.terraform_remote_state.s3.outputs.superset_kms_key_id
  }
}

resource "aws_athena_workgroup" "superset_workgroup" {
  name = "${var.tenant}-${var.environment}-${var.stage}-superset-wg"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${data.terraform_remote_state.s3.outputs.athena_output_bucket_id}/query-results/"
    }
  }
  depends_on = [aws_athena_database.superset_database]
}
