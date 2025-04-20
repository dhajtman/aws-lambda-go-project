# AWS Lambda Go Project

This project is a simple AWS Lambda function written in Go. It serves as a template for creating and deploying Lambda functions using the Go programming language.

## Project Structure

```
aws-lambda-go-project
├── src
│   ├── main.go        # Entry point of the Lambda function
│   └── handler.go     # Contains the main handler function
├── go.mod             # Module definition file
├── go.sum             # Checksums for module dependencies
└── README.md          # Project documentation
```

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

2. Create a new Lambda function using the AWS CLI:

   ```
   aws lambda create-function --function-name YourFunctionName --zip-file fileb://deployment.zip --handler main --runtime go1.x --role YourIAMRoleARN
   ```

3. Update the function code if needed:

   ```
   aws lambda update-function-code --function-name entsoe-scraper --zip-file fileb://../main.zip
   ```

### Testing the Function

You can test the function using the AWS Lambda console or by invoking it via the AWS CLI:

```
aws lambda invoke --function-name YourFunctionName output.txt
```

### License

This project is licensed under the MIT License. See the LICENSE file for details.