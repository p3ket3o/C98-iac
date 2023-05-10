output "https_arn" {
  value = aws_lb_listener.https443.arn
}

output "alb_dns" {
  value = aws_lb.this.dns_name
}

output "acm_name" {
  value = aws_acm_certificate.this.domain_validation_options[*].resource_record_name
}

output "acm_value" {
  value = aws_acm_certificate.this.domain_validation_options[*].resource_record_value
}