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

### Building the Project

To build the project, run:

```
GOOS=linux GOARCH=amd64 go build -tags lambda.norpc -o bootstrap ./src/main.go
```

### Deploying to AWS Lambda

1. Zip the binary:

   ```
   zip main.zip bootstrap
   ```

2. Deploy HCL:

   ```
   cd terraform
   terraform apply -var-file=terraform_A75.tfvars
   ```

3. Update the function code if needed:

   ```
   aws lambda update-function-code --function-name entsoe-scraper --zip-file fileb://../main.zip
   ```

4. Destroy IaaC
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

### License

This project is licensed under the MIT License. See the LICENSE file for details.