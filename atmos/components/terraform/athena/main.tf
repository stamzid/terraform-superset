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

resource "aws_glue_catalog_database" "superset_database" {
  name = "${var.tenant}_${var.environment}_${var.stage}_superset_glue_db"
}

resource "aws_glue_catalog_table" "superset_table" {
  name          = "superset_table"
  database_name = aws_glue_catalog_database.superset_database.name

  storage_descriptor {
    location      = "s3://${data.terraform_remote_state.s3.outputs.superset_data_bucket_id}/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim" = ","
        "serialization.null.format" = ""
        "escape.delim" = "\\"
      }
    }

    columns {
      name = "draw_date"
      type = "string"
    }
    columns {
      name = "winning_numbers"
      type = "string"
    }
    columns {
      name = "mega_ball"
      type = "string"
    }
    columns {
      name = "multiplier"
      type = "string"
    }
  }

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "classification" = "csv"
  }
}

resource "aws_athena_workgroup" "superset_workgroup" {
  name = "${var.tenant}-${var.environment}-${var.stage}-superset-wg"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${data.terraform_remote_state.s3.outputs.athena_output_bucket_id}/query-results/"
      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = data.terraform_remote_state.s3.outputs.superset_kms_key_arn
      }
    }
  }

  depends_on = [aws_glue_catalog_database.superset_database]
}
