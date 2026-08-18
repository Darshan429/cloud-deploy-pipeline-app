variable "project_name" {
  type    = string
  default = "clouddeploy"
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "my_ip" {
  description = "Your current public IP (no CIDR suffix) — SSH and Jenkins UI access are restricted to this"
  type        = string
}

variable "key_name" {
  description = "Name of an existing EC2 key pair in this AWS region"
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t3.small" # t3.micro is free-tier but Jenkins is tight on 1GB RAM
}
