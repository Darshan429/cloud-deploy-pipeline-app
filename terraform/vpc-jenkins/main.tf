provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

module "jenkins" {
  source = "./modules/ec2-jenkins"

  project_name  = var.project_name
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnet_ids[0]
  my_ip         = var.my_ip
  key_name      = var.key_name
  instance_type = var.instance_type
}
