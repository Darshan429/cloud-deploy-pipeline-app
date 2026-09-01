variable "aws_region" {
  type    = string
  default = "ap-south-2"
}

variable "vpc_id" {
  description = "Existing VPC ID from your vpc-jenkins config's output"
  type        = string
}

variable "subnet_id" {
  description = "Existing public subnet ID from your vpc-jenkins config's output"
  type        = string
}

variable "my_ip" {
  type = string
}

variable "key_name" {
  type = string
}
