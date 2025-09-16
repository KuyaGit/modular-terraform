output "repository_url" {
  value       = aws_ecr_repository.main.repository_url
  description = "The URL of the repository"
}

output "repository_name" {
  value       = aws_ecr_repository.main.name
  description = "The name of the repository"
} 