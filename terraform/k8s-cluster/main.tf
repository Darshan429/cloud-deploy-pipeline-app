terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Same state bucket as vpc-jenkins, different key — one bucket can hold
  # multiple Terraform configs' state, as long as each has a unique path.
  backend "s3" {
    bucket         = "clouddeploy-tfstate-notes-api" # match your actual bucket
    key            = "clouddeploy/k8s-cluster/terraform.tfstate"
    region         = "ap-south-2"                     # match your actual region
    dynamodb_table = "clouddeploy-tf-locks-notes-api"  # match your actual table
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# Reuses the SAME VPC your Jenkins server already lives in — no need to
# provision a second network. Pass in the existing VPC/subnet IDs.
module "k8s_nodes" {
  source = "./modules/k8s-nodes"
  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  my_ip         = var.my_ip
  key_name      = var.key_name
}
