resource "aws_route53_record" "a_record" {
  # count   = var.alb_dns_name != null && var.alb_zone_id != null ? 1 : 0
  zone_id = var.route53_zone_id
  name    = var.record_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# NS Record (for delegation)
# resource "aws_route53_record" "ns_delegation" {
#   count   = length(var.delegated_ns) > 0 ? 1 : 0
#   zone_id = var.route53_zone_id
#   name    = var.record_name
#   type    = "NS"
#   ttl     = 300
#   records = var.delegated_ns
# }