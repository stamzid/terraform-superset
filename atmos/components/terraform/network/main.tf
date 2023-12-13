data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "stamzid-tfstate"
    key    = "vpc/${var.tenant}-${var.environment}-${var.stage}/terraform.tfstate"
    region = var.region
  }
}

resource "aws_acm_certificate" "superset_cert" {
  domain_name       = "${var.stage}.superset.stamzid.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "superset_cert_record" {
  name    = tolist(aws_acm_certificate.superset_cert.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.superset_cert.domain_validation_options)[0].resource_record_type
  zone_id = var.hosted_zone_id
  records = [tolist(aws_acm_certificate.superset_cert.domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "superset_cert_validation" {
  certificate_arn         = aws_acm_certificate.superset_cert.arn
  validation_record_fqdns = [aws_route53_record.superset_cert_record.fqdn]
}

resource "aws_lb" "app_lb" {
  name               = "${var.tenant}-${var.environment}-${var.stage}-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.terraform_remote_state.vpc.outputs.alb_sg_id]
  subnets            = data.terraform_remote_state.vpc.outputs.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "app-lb"
  }
}

resource "aws_lb_target_group" "superset_tg" {
  name     = "${var.tenant}-${var.environment}-${var.stage}-superset-tg"
  port     = 8088
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id

  target_type = "ip"

  health_check {
    protocol            = "HTTP"
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 60
    matcher             = "200,302,308"
  }

  tags = {
    Name = "superset-tg"
  }
}

resource "aws_lb_listener" "https_superset_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.superset_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.superset_tg.arn
  }

  depends_on = [aws_acm_certificate_validation.superset_cert_validation]
}
