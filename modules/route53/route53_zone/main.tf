# resource "aws_route53_zone" "subdomain_zone" {
#   name     = var.record_name
#   comment  = "Delegated subdomain zone"
# }

# resource "aws_acm_certificate" "cert" {
#   domain_name       = var.record_name
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_route53_record" "cert_validation" {
#   zone_id = aws_route53_zone.subdomain_zone.zone_id
#   name    = aws_acm_certificate.cert.domain_validation_options[0].resource_record_name
#   type    = aws_acm_certificate.cert.domain_validation_options[0].resource_record_type
#   ttl     = 300
#   records = [aws_acm_certificate.cert.domain_validation_options[0].resource_record_value]
# }

# resource "aws_acm_certificate_validation" "cert_validation" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
# }