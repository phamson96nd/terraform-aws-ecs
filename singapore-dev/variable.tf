variable "app_name" {
  type = string
}

variable "region" {
  type    = string
  default = "ap-southeast-1"
}

#parameters for networking module
variable "availability_zones" {
  type     = list(string)
  nullable = false
}
variable "cidr_block" {
  type     = string
  nullable = false
}

variable "public_subnet_ips" {
  type     = list(string)
  nullable = false

}
variable "private_subnet_ips" {
  type     = list(string)
  nullable = false
}

# optional list of SSH public keys for bastion authorized_keys
variable "extra_public_keys" {
  description = "List of public keys to add to the bastion authorized_keys"
  type        = list(string)
  default     = []
}

# Database
variable "db_name" {
  type = string
}

# ECR 
variable "ecr_info" {
  type = object({
    image = string
    tag   = string
  })
}

# GIT
variable "git_config" {
  type = object({
    github_owner            = string
    github_repo             = string
    github_branch           = string
    codestar_connection_arn = string
  })
}
