variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
  description = "The VPC ID"
  nullable = false
}

variable "app_name" {
  type = string
}