provider "aws" {
  region = var.region
}

#1. Create a complete VPC using module networking
module "networking" {
  source             = "../modules/networking"
  region             = var.region
  app_name           = var.app_name
  availability_zones = var.availability_zones
  cidr_block         = var.cidr_block
  public_subnet_ips  = var.public_subnet_ips
  private_subnet_ips = var.private_subnet_ips
}

#2. Security
module "security" {
  source   = "../modules/security"
  region   = var.region
  app_name = var.app_name
  vpc_id   = module.networking.vpc_id
}

#3. Bastion
module "bastion" {
  source        = "../modules/bastion"
  region        = var.region
  app_name      = var.app_name
  instance_type = "t3.small"
  security_group_ids = [
    module.security.bastion_security_group_id
  ]
  subnet_id = module.networking.public_subnet_ids[0] // public subnet zone 1
}

#4. Database
module "database" {
  source                 = "../modules/database"
  app_name               = var.app_name
  vpc_security_group_ids = [module.security.database_security_group_id]
  subnet_ids             = module.networking.private_subnet_ids // private subnet zone 1 and 2
}

#5. Load balancer
module "load_balance" {
  source                  = "../modules/load_balance"
  region                  = var.region
  app_name                = var.app_name
  vpc_id                  = module.networking.vpc_id
  load_balance_subnet_ids = module.networking.public_subnet_ids // public subnet zone 1 and 2
  load_balance_security_group_ids = [
    module.security.public_security_group_id
  ]
}

#6. ECS
module "ecs_cluster" {
  source   = "../modules/ecs_cluster"
  region   = var.region
  app_name = var.app_name

  vpc_id         = module.networking.vpc_id
  ecs_subnet_ids = module.networking.private_subnet_ids // private subnet zone 1 and 2
  ecs_security_group_ids = [
    module.security.private_security_group_id
  ]

  alb_arn = module.load_balance.alb_arn

  # frontend_target_group_arn = module.load_balance.frontend_target_group_arn
  # frontend_ecr_image_url = var.frontend_ecr_repo_url

  backend_target_group_arn = module.load_balance.backend_target_group_arn
  backend_ecr_image_url    = "${module.ecr.ecr_repository_image_url}:${var.ecr_info.tag}"

  alb_dns = "http://${module.load_balance.alb_dns}:80"

  db_username = module.database.rds_secret_username_valuefrom
  db_password = module.database.rds_secret_password_valuefrom
  db_host     = module.database.rds_host
  db_name     = var.db_name
}

#7. ECR
module "ecr" {
  source          = "../modules/ecr"
  region          = var.region
  ecr_imange_name = var.ecr_info.image
}

#8. Codebuild and Code Pipeline
module "codepipeline" {
  source   = "../modules/codepipeline"
  region   = var.region
  app_name = var.app_name

  git_config = var.git_config

  ecr_info = var.ecr_info
  ecr_url  = module.ecr.ecr_repository_url

  ecs_cluster_name = module.ecs_cluster.ecs_cluster_name
  ecs_service_name = module.ecs_cluster.ecs_service_name
}
