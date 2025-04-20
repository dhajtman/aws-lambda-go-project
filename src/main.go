package main

import (
	"context"

	"github.com/aws/aws-lambda-go/lambda"
)

// HandleRequest processes the incoming Lambda event
func HandleRequest(ctx context.Context, event map[string]interface{}) (string, error) {
	return "Hello from AWS Lambda!", nil
}

func main() {
	lambda.Start(HandleRequest)
}
