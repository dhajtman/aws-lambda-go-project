api_url       = "https://web-api.tp.entsoe.eu/api?documentType={document_type}&processType={process_type}&in_Domain={in_domain}&periodStart={period_start}&periodEnd={period_end}&securityToken={api_url_token}"
document_type = "A71" # Generation forecast
process_type  = "A01" # Day ahead
in_domain     = "10YBE----------2" # Control Area, Bidding Zone, Country
period_start  = "202308152200" # Start period (Pattern yyyyMMddHHmm e.g. 201601010000)
period_end    = "202308162200" # End period (Pattern yyyyMMddHHmm e.g. 201601010000)
schedule_expression = "rate(1 day)" # Default value
s3_bucket     = "entsoe-data-buckets"
output_prefix = "entsoe-data"
secret_token_name = "entsoe_api_token3" # Name of the secret in AWS Secrets Manage
api_url_token = "90765852-0497-41e0-b46f-8b0f49c57ca0"