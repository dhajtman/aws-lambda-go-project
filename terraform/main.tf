# This Terraform script sets up an AWS Lambda function to scrape data from the ENTSOE API
provider "aws" {
  region = "us-east-1"
}

# Create an S3 bucket for storing data
resource "aws_s3_bucket" "entsoe_data" {
  bucket = var.s3_bucket
}

# Create role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "entsoe-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda to access S3 and CloudWatch
resource "aws_iam_policy" "lambda_policy" {
  name = "entsoe-lambda-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.entsoe_data.arn}/*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach the IAM policy to the role
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Create a Lambda function
resource "aws_lambda_function" "entsoe_scraper" {
  function_name = "entsoe-scraper"
  role          = aws_iam_role.lambda_role.arn
  handler       = "bootstrap" # The entry point for the Lambda function
  runtime       = "provided.al2023"
  filename      = "../main.zip" # Path to the zipped Lambda function code
  timeout       = 60
  architectures = ["arm64"] # Set the architecture to arm64

  # VPC configuration
  vpc_config {
    subnet_ids         = [aws_subnet.private.id] # Reference the private subnet
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  # Environment variables
  environment {
    variables = {
      API_URL           = var.api_url
      API_URL_TOKEN     = jsondecode(data.aws_secretsmanager_secret_version.api_token.secret_string).api_url_token
      DOCUMENT_TYPE     = var.document_type
      PROCESS_TYPE      = var.process_type
      IN_DOMAIN         = var.in_domain
      PERIOD_START      = var.period_start
      PERIOD_END        = var.period_end
      S3_BUCKET         = aws_s3_bucket.entsoe_data.bucket
      OUTPUT_PREFIX     = var.output_prefix
      # JAVA_TOOL_OPTIONS = "-Djdk.internal.httpclient.debug=true"
    }
  }
}

# Create a Secrets Manager secret
resource "aws_secretsmanager_secret" "api_token" {
  name        = var.secret_token_name # Unique name for the secret, may required to be changed after deletion since recovery window is 7 days
  description = "API token for accessing the ENTSOE API"
}

# Store the API token in the secret
resource "aws_secretsmanager_secret_version" "api_token_version" {
  secret_id     = aws_secretsmanager_secret.api_token.id
  secret_string = jsonencode({
    api_url_token = var.api_url_token # Replace with your actual token
  })
}

# Retrieve the API token from Secrets Manager
data "aws_secretsmanager_secret_version" "api_token" {
  secret_id = aws_secretsmanager_secret.api_token.id

  # Ensure the secret version is created before this data block is executed
  depends_on = [aws_secretsmanager_secret_version.api_token_version]
}

# IAM Policy for accessing Secrets Manager
resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "secrets-manager-access-policy"
  description = "Policy to allow Lambda access to Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.api_token.arn
      }
    ]
  })
}

# Attach the policy to the Lambda role
resource "aws_iam_role_policy_attachment" "secrets_manager_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Create an Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Create a public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Create a NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
}

# Create a NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}

# Create a private subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
}

# Create a route table for the public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

# Associate the public route table with the public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create a route table for the private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
}

# Associate the private route table with the private subnet
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Create a security group for the Lambda function
resource "aws_security_group" "lambda_sg" {
  name        = "lambda-sg"
  description = "Allow internet access for Lambda"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EventRule to trigger Lambda function
resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "entsoe-scraper-schedule"
  schedule_expression = var.schedule_expression
}

# Create Event Target to invoke Lambda function
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "entsoe-scraper"
  arn       = aws_lambda_function.entsoe_scraper.arn
}

# Create permission for CloudWatch to invoke Lambda function
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.entsoe_scraper.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}