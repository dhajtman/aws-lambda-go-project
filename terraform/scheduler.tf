# This file contains the configuration for the AWS Lambda function that will be triggered by a CloudWatch Event Rule.

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