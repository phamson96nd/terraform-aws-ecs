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
