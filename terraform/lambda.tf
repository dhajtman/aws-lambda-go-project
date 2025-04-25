# This file contains the Terraform configuration for deploying the AWS Lambda function

# Create a Lambda function
resource "aws_lambda_function" "entsoe_scraper" {
  function_name = "entsoe-scraper"
  role          = aws_iam_role.lambda_role.arn
  handler       = var.handler # The entry point for the Lambda function
  runtime       = var.runtime
  filename      = var.filename # Path to the zipped Lambda function code
  timeout       = var.timeout
  architectures = var.architectures # Set the architecture to arm64
  memory_size   = var.memory_size # Memory size in MB

  vpc_config {
    subnet_ids         = [aws_subnet.private.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      API_URL       = var.entsoe_api_url
      API_URL_TOKEN = jsondecode(data.aws_secretsmanager_secret_version.api_token.secret_string).api_url_token
      DOCUMENT_TYPE = var.document_type
      PROCESS_TYPE  = var.process_type
      IN_DOMAIN     = var.in_domain
      PERIOD_START  = var.period_start
      PERIOD_END    = var.period_end
      TARGET_KEY    = var.target_key
      S3_BUCKET     = aws_s3_bucket.entsoe_data.bucket
      OUTPUT_PREFIX = var.output_prefix
    }
  }
}