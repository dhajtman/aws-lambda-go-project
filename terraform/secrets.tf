# This file contains the configuration for AWS Secrets Manager to store sensitive information.

# Create a Secrets Manager secret
resource "aws_secretsmanager_secret" "api_token" {
  name        = var.secret_token_name
  description = "API token for accessing the ENTSOE API"
}

# Store the API token in the secret
resource "aws_secretsmanager_secret_version" "api_token_version" {
  secret_id     = aws_secretsmanager_secret.api_token.id
  secret_string = jsonencode({
    api_url_token = var.entsoe_api_url_token
  })
}

# Retrieve the API token from Secrets Manager
data "aws_secretsmanager_secret_version" "api_token" {
  secret_id  = aws_secretsmanager_secret.api_token.id

  # Ensure the secret version is created before this data block is executed
  depends_on = [aws_secretsmanager_secret_version.api_token_version]
}