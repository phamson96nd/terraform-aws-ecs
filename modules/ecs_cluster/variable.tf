variable "region" {
  type = string
}

variable "app_name" {
  type = string
}

variable "vpc_id" {
  type     = string
  nullable = false
}

variable "ecs_subnet_ids" {
  type     = list(string)
  nullable = false
}

variable "ecs_security_group_ids" {
  type     = list(string)
  nullable = false
}
variable "alb_arn" {
  type     = string
  nullable = false
}
# variable "frontend_target_group_arn" {
#   type        = string
#   description = "The ARN of the target group for the Frontend ECS Service"
#   nullable    = false
# }
# variable "frontend_ecr_image_url" {
#   type        = string
#   description = "The URI of the ECR repository for the Node.js application"
#   nullable    = false
# }

variable "backend_target_group_arn" {
  type        = string
  description = "The ARN of the target group for the ECS Service"
  nullable    = false
}
variable "backend_ecr_image_url" {
  type        = string
  description = "The URI of the ECR repository for the Node.js application"
  nullable    = false
}

variable "alb_dns" {
  type     = string
  nullable = false
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_host" {
  type = string
}

variable "db_name" {
  type = string
}
