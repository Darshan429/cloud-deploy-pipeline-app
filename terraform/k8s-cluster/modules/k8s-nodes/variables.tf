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
  description = "Your current public IP, no CIDR suffix — for SSH and kubectl access"
  type        = string
}

variable "key_name" {
  type = string
}

variable "control_plane_instance_type" {
  type    = string
  default = "t3.small" # kubeadm's control plane needs more than t3.small comfortably handles
}

variable "worker_instance_type" {
  type    = string
  default = "t3.small"
}
