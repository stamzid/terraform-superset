data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "stamzid-tfstate"
    key    = "vpc/${var.tenant}-${var.environment}-${var.stage}/terraform.tfstate"
    region = var.region
  }
}
