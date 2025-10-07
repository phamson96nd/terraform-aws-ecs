variable "app_name" {
  type = string
}

variable "instance_type" {
  type        = string
  description = "Type of EC2 instance to launch. Example: t2.small"
  default     = "t3.small"
}

variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "security_group_ids" {
  type    = list(string)
  default = ["default"]
}

variable "subnet_id" {
  type = string
}

#list keypair
variable "users" {
  description = "list"
  type        = set(string)
  default     = ["user1", "user2"]
}