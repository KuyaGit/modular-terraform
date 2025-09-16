output "aurora_proxy_endpoint" {
  value = aws_ssm_parameter.aurora_proxy_endpoint.value
}
