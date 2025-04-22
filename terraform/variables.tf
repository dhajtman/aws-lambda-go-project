variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "entsoe_api_url" {
  type        = string
  description = "The API URL for the ENTSOE scraper"
  default = "https://web-api.tp.entsoe.eu/api?documentType={document_type}&processType={process_type}&in_Domain={in_domain}&periodStart={period_start}&periodEnd={period_end}&securityToken={api_url_token}"
}

variable "document_type" {
  type        = string
  description = "Document type for the ENTSOE API (A71 = Generation forecast)"
  default = "A71" # Replace with your actual document type
}

variable "process_type" {
  type        = string
  description = "Process type for the ENTSOE API (A01 = Day ahead)"
  default = "A01" # Replace with your actual process type
}

variable "in_domain" {
  type        = string
  description = "Domain for the ENTSOE API (Control Area, Bidding Zone, Country)"
  default = "10YBE----------2" # Replace with your actual domain
}

variable "period_start" {
  type        = string
  description = "Start period for the ENTSOE API (Pattern yyyyMMddHHmm e.g. 201601010000)"
  default = "202308152200" # Replace with your actual start period
}

variable "period_end" {
  type        = string
  description = "End period for the ENTSOE API (Pattern yyyyMMddHHmm e.g. 201601010000)"
  default = "202308162200" # Replace with your actual end period
}

variable "target_key" {
  type        = string
  description = "The target key to parse ENTSOE API response"
  default = "quantity" # Replace with your actual target key
}

variable "schedule_expression" {
  description = "The schedule expression for the CloudWatch Event Rule"
  type        = string
  default     = "rate(1 day)" # Default value
}

variable "secret_token_name" {
  type        = string
  description = "The name of the secret in AWS Secrets Manager"
  default = "entsoe_api_token" # # Unique name for the secret, may required to be changed after deletion since recovery window is 7 days
}

variable "s3_bucket_name" {
  type        = string
  description = "The S3 bucket name for storing data"
  default = "entsoe-data-bucket" # Replace with your actual bucket name
}

variable "output_prefix" {
  type        = string
  description = "The prefix for the output files in S3"
  default = "entsoe-data" # Replace with your actual output prefix
}

variable "entsoe_api_url_token" {
  type        = string
  description = "Token for accessing the ENTSOE API"
  sensitive   = true
}