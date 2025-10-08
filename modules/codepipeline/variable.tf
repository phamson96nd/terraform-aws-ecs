variable "app_name" {
  type = string
}
variable "region" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_name" {
  type = string
}

variable "ecr_info" {
  type = object({
    image = string
    tag   = string
  })
}

variable "ecr_url" {
  type = string
}

variable "git_config" {
  type = object({
    github_owner            = string
    github_repo             = string
    github_branch           = string
    codestar_connection_arn = string
  })
}
