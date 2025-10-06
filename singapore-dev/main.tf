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
