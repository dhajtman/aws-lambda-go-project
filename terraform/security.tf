# This file contains the security group configuration for the Lambda function.

# Create a security group for the Lambda function
resource "aws_security_group" "lambda_sg" {
  name        = "lambda-sg"
  description = "Allow internet access for Lambda"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
