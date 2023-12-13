terraform {
  backend "s3" {
    bucket               = "stamzid-tfstate"
    key                  = "terraform.tfstate"
    region               = "us-east-1"
    dynamodb_table       = "stamzid-tfstate-lock"
    encrypt              = true
    workspace_key_prefix = "ecr"
  }
}
