output "alb_id" {
  description = "ID of the ALB"
  value       = module.alb.lb_id
}

output "alb_arn" {
  description = "ARN of the ALB"
  value       = module.alb.lb_arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb.lb_dns_name
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = module.alb.http_tcp_listener_arns[0]
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = length(module.alb.https_listener_arns) > 0 ? module.alb.https_listener_arns[0] : null
}

output "zone_id" {
  description = "Zone ID of ALB"
  value       = module.alb.lb_zone_id
}