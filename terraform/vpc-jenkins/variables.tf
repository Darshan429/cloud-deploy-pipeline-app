variable "aws_region" {
  type    = string
  default = "ap-south-2"
}

variable "project_name" {
  type    = string
  default = "clouddeploy"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "my_ip" {
  description = "Your current public IP, no CIDR suffix (get it from https://checkip.amazonaws.com). SSH/Jenkins UI are locked to this."
  type        = string
}

variable "key_name" {
  description = "Name of an EC2 key pair you already created in the AWS console (EC2 > Key Pairs) in this region"
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}
