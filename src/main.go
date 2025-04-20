package main

import (
	"bytes"
	"context"
	"encoding/csv"
	"encoding/xml"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	s3 "github.com/aws/aws-sdk-go-v2/service/s3"
)

type Point struct {
	Quantity string `xml:"quantity"`
}

type Period struct {
	Points []Point `xml:"Point"`
}

type TimeSeries struct {
	Period Period `xml:"Period"`
}

type ResponseXML struct {
	TimeSeries TimeSeries `xml:"TimeSeries"`
}

func handleRequest(ctx context.Context) (string, error) {
	log.Println("Starting the Lambda function...")

	// Load environment variables
	apiUrlTemplate := getEnv("API_URL", "https://web-api.tp.entsoe.eu/api?documentType={document_type}&processType={process_type}&in_Domain={in_domain}&periodStart={period_start}&periodEnd={period_end}&securityToken={api_url_token}")
	apiUrlToken := getEnv("API_URL_TOKEN", "xxxxxx")
	documentType := getEnv("DOCUMENT_TYPE", "A71")
	processType := getEnv("PROCESS_TYPE", "A01")
	inDomain := getEnv("IN_DOMAIN", "10YBE----------2")
	periodStart := getEnv("PERIOD_START", "202308152200")
	periodEnd := getEnv("PERIOD_END", "202308162200")

	bucketName := getEnv("S3_BUCKET", "entsoe-data-bucket")
	outputPrefix := getEnv("OUTPUT_PREFIX", "entsoe_data_")

	apiUrl := assemblyApiUrl(apiUrlTemplate, documentType, processType, inDomain, periodStart, periodEnd, apiUrlToken)
	log.Printf("Fetching data from API URL: %s", apiUrl)

	// Fetch data from API
	xmlData, err := fetchDataFromApi(apiUrl)
	if err != nil {
		return "", err
	}
	log.Println("Fetched XML data from API")

	// Parse and process data
	quantities, err := processData(xmlData)
	if err != nil {
		return "", err
	}
	log.Printf("Extracted data: %v", quantities)

	// Convert to CSV
	var buf bytes.Buffer
	writer := csv.NewWriter(&buf)
	if err := writer.Write(quantities); err != nil {
		return "", err
	}
	writer.Flush()

	// Upload to S3
	fileName := fmt.Sprintf("%s-%s.csv", outputPrefix, time.Now().Format("20060102T150405"))
	if err := uploadToS3(ctx, bucketName, fileName, buf.Bytes()); err != nil {
		return "", err
	}
	log.Printf("Data uploaded to S3: %s", fileName)

	return "Success", nil
}

func getEnv(key, fallback string) string {
	if val, ok := os.LookupEnv(key); ok {
		return val
	}
	return fallback
}

func assemblyApiUrl(template, docType, procType, domain, start, end, token string) string {
	return strings.NewReplacer(
		"{document_type}", docType,
		"{process_type}", procType,
		"{in_domain}", domain,
		"{period_start}", start,
		"{period_end}", end,
		"{api_url_token}", token,
	).Replace(template)
}

func fetchDataFromApi(url string) ([]byte, error) {
	resp, err := http.Get(url)
	if err != nil {
		return nil, fmt.Errorf("error fetching API data: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("API returned status: %d", resp.StatusCode)
	}

	return io.ReadAll(resp.Body)
}

func processData(xmlData []byte) ([]string, error) {
	var result ResponseXML
	if err := xml.Unmarshal(xmlData, &result); err != nil {
		return nil, fmt.Errorf("error parsing XML: %w", err)
	}

	var values []string
	for _, point := range result.TimeSeries.Period.Points {
		values = append(values, point.Quantity)
	}
	return values, nil
}

func uploadToS3(ctx context.Context, bucket, key string, data []byte) error {
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return fmt.Errorf("unable to load AWS SDK config: %w", err)
	}

	client := s3.NewFromConfig(cfg)
	_, err = client.PutObject(ctx, &s3.PutObjectInput{
		Bucket: aws.String(bucket),
		Key:    aws.String(key),
		Body:   bytes.NewReader(data),
	})
	return err
}

func main() {
	lambda.Start(handleRequest)
}
