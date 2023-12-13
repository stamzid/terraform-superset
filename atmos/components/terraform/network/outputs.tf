output "superset_certificate_arn" {
  value = aws_acm_certificate.superset_cert.arn
}

output "alb_dns" {
  value = aws_lb.app_lb.dns_name
}

output "superset_tg_arn" {
  value = aws_lb_target_group.superset_tg.arn
}

output "alb_arn" {
  value = aws_lb.app_lb.arn
}

output "https_listener_arn" {
  value = aws_lb_listener.https_superset_listener.arn
}
