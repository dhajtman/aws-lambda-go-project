terraform {
  backend "s3" {
    bucket         = "entsoe-backend-bucket"       # Replace with your S3 bucket name
    key            = "terraform.tfstate"    # Replace with the desired path for the state file
    region         = "us-east-1"                # Replace with your AWS region
  }
}