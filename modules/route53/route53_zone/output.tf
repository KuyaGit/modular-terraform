output "subdomain_name_servers" {
  value = aws_route53_zone.subdomain_zone.name_servers
}