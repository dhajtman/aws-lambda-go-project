# AWS Lambda Go Project

This project is a simple AWS Lambda function written in Go. It serves as a template for creating and deploying Lambda functions using the Go programming language.

## Building Lambda functions with Go
https://docs.aws.amazon.com/lambda/latest/dg/lambda-golang.html

## Migrating AWS Lambda functions from the Go1.x runtime to the custom runtime on Amazon Linux 2
https://aws.amazon.com/blogs/compute/migrating-aws-lambda-functions-from-the-go1-x-runtime-to-the-custom-runtime-on-amazon-linux-2/

## Getting Started

### Prerequisites

- Go installed on your machine (version 1.15 or later)
- AWS CLI configured with your credentials
- AWS Lambda permissions to deploy functions

### Installation

1. Clone the repository:

   ```
   git clone https://github.com/yourusername/aws-lambda-go-project.git
   cd aws-lambda-go-project
   ```

2. Install dependencies:

   ```
   go mod tidy
   ```

### Building and pack the Project

To build the project, run:

```
GOOS=linux GOARCH=arm64 go build -tags lambda.norpc -o bootstrap ./src/main.go
zip main.zip bootstrap
```

### Create your .tfvars file
   ```
   entsoe_api_url  = "https://web-api.tp.entsoe.eu/api?documentType={document_type}&processType={process_type}&in_Domain={in_domain}&periodStart={period_start}&periodEnd={period_end}&securityToken={api_url_token}"
   document_type = "A75" # A75 = Actual generation per type (all production types)
   process_type  = "A16" # A16 = Realised
   in_domain     = "10Y1001A1001A83F" # Control Area, Bidding Zone, Country
   period_start  = "202308152200" # Start period (Pattern yyyyMMddHHmm e.g. 201601010000)
   period_end    = "202308162200" # End period (Pattern yyyyMMddHHmm e.g. 201601010000)
   target_key    = "quantity" # The target key to parse ENTSOE API response
   schedule_expression = "rate(1 day)" # Default value
   s3_bucket_name     = "entsoe-data-buckets"
   output_prefix = "entsoe-data"
   secret_token_name = "entsoe_api_token6" # Name of the secret in AWS Secrets Manage
   entsoe_api_url_token = "xxx"
   ```

### Apply Terraform configuration
1. Deploy HCL:

   ```
   cd terraform
   terraform apply -var-file=terraform_A75.tfvars
   ```

3. Update the function code if needed:

   ```
   aws lambda update-function-code --function-name entsoe-scraper --zip-file fileb://../main.zip
   ```

4. Destroy Terraform configuration
   ```
   terraform destroy -var-file=terraform_A75.tfvars   
   ```

5. If required, deleting ENI or you may need to wait
   ```
   aws ec2 delete-network-interface --network-interface-id eni-1234567890abcdef0
   ```

### Testing the Function

You can test the function using the AWS Lambda console or by invoking it via the AWS CLI:

```
aws lambda invoke --function-name YourFunctionName output.txt
```

