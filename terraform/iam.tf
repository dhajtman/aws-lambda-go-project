# This Terraform configuration file sets up IAM roles and policies for AWS Lambda functions

# Create role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "entsoe-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# IAM Policy for Lambda to access S3 and CloudWatch
resource "aws_iam_policy" "lambda_policy" {
  name = "entsoe-lambda-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["s3:PutObject", "s3:GetObject"],
        Effect = "Allow",
        Resource = "${aws_s3_bucket.entsoe_data.arn}/*"
      },
      {
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Effect = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = ["ec2:CreateNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DeleteNetworkInterface"],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

# IAM Policy for accessing Secrets Manager
resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "secrets-manager-access-policy"
  description = "Policy to allow Lambda access to Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"],
        Effect = "Allow",
        Resource = aws_secretsmanager_secret.api_token.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Attach the IAM policy for Secrets Manager to the role
resource "aws_iam_role_policy_attachment" "secrets_manager_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}