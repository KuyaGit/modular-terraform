module "ecr" {
  source              = "../modules/ecr"
  prefix              = local.name_prefix
  ecr_repository_name = local.ecr_repository_name
}

output "repository_url" {
  value       = module.ecr.repository_url
  description = "The URL of the repository"
} 