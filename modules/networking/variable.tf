# variables.tf
variable "app_name" {
  type = string
}

variable "region" {
  type = string
}

variable "cidr_block" {
  type = string
  nullable = false
}

variable "availability_zones"{
  type = list(string)
  nullable = false
}

variable "public_subnet_ips" {
  type = list(string)
  nullable = false
}

variable "private_subnet_ips" {
  type = list(string)
  nullable = false
}