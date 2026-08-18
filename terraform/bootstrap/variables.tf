variable "aws_region" {
  description = "AWS region to create the state bucket/lock table in"
  type        = string
  default     = "ap-south-2"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform remote state"
  type        = string
  # S3 bucket names are global across ALL AWS accounts, not just yours.
  # Change this to something unique, e.g. clouddeploy-tfstate-<yourname>-<random>
  default     = "clouddeploy-tfstate-notes-api"
}

variable "lock_table_name" {
  description = "DynamoDB table name used for Terraform state locking"
  type        = string
  default     = "clouddeploy-tf-locks-notes-api"
}
