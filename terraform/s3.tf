# This file contains the S3 bucket resource definition for storing ENTSO-E data.

# Create an S3 bucket for storing data
resource "aws_s3_bucket" "entsoe_data" {
  bucket = var.s3_bucket_name
}