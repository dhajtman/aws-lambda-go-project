# This file contains the provider configuration for Terraform.

# It specifies the AWS provider and the region to be used for resource creation.
provider "aws" {
  region = var.aws_region
}