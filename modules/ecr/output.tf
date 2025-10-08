# Output repository URL
output "ecr_repository_url" {
  value = split("/", aws_ecr_repository.app.repository_url)[0]
}


output "ecr_repository_image_url" {
  value = aws_ecr_repository.app.repository_url
}
