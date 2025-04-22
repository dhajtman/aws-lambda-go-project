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
entsoe_api_url_token = "xxxxxxxxx-0497-41e0-b46f-8b0f49c57ca0" # Replace with your actual token