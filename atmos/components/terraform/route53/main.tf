data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "stamzid-tfstate"
    key    = "network/${var.tenant}-${var.environment}-${var.stage}/terraform.tfstate"
    region = var.region
  }
}

data "aws_elb_hosted_zone_id" "main" {}

resource "aws_route53_record" "api" {
  zone_id = var.hosted_zone_id
  name    = "${var.stage}.superset.stamzid.com"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.network.outputs.alb_dns
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = false
  }
}
