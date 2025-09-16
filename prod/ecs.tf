module "ecs_cluster" {
  source = "../modules/ecs-cluster"

  cluster_name                           = local.cluster_name
  service_connect_cloudmap_namespace_arn = aws_service_discovery_http_namespace.service_connect_cloudmap.arn

  # Enable container insights for better monitoring in development
  enable_container_insights = true
}

resource "aws_service_discovery_http_namespace" "service_connect_cloudmap" {
  name        = "${var.environment}-ns"
  description = "Namespace for ${var.environment} services"
}
