terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # NOTE: backend blocks cannot use variables — these values must be
  # hardcoded. Replace both after running `terraform apply` in ../bootstrap
  # and reading its outputs.
  backend "s3" {
    bucket         = "clouddeploy-tfstate-notes-api"
    key            = "clouddeploy/vpc-jenkins/terraform.tfstate"
    region         = "ap-south-2"
    dynamodb_table = "clouddeploy-tf-locks-notes-api"
    encrypt        = true
  }
}
