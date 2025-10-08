app_name = "laravel"

region = "ap-southeast-1"

# 1. Networking
availability_zones = ["ap-southeast-1a", "ap-southeast-1c"]
cidr_block         = "10.0.0.0/16"
public_subnet_ips  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_ips = ["10.0.10.0/24", "10.0.20.0/24"]

#4. Database
db_name = "prod_laravel_api"

#6. ECR
# frontend_ecr_repo_url = "826895066148.dkr.ecr.ap-southeast-1.amazonaws.com/devops-final-assignment-frontend:latest"
backend_ecr_repo_url = "826895066148.dkr.ecr.ap-southeast-1.amazonaws.com/prod-base-image:latest"

#GIT
git_config = {
  github_owner            = "phamson96nd"
  github_repo             = "laravel-api-v3"
  github_branch           = "main"
  codestar_connection_arn = "arn:aws:codeconnections:ap-southeast-1:826895066148:connection/065120d0-262d-4815-8c21-08381415d734"
}


