output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.serverless_app.lambda_function_name
}

output "dynamodb_table_names" {
  description = "Names of the DynamoDB tables (if created)"
  value       = module.serverless_app.dynamodb_table_names
}

output "api_gateway_invoke_urls" {
  description = "Map of API Gateway URLs (if enabled)"
  value       = module.serverless_app.api_gateway_invoke_urls
}

# Cognito resources
output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.serverless_app.cognito_user_pool_id
}

output "cognito_user_pool_client_id" {
  description = "Cognito App Client ID"
  value       = module.serverless_app.cognito_user_pool_client_id
}


#SNS and SQS Outputs 
output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = module.serverless_app.sns_topic_arn
}

output "sqs_queue_url" {
  description = "URL of the SQS queue"
  value       = module.serverless_app.sqs_queue_url
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue"
  value       = module.serverless_app.sqs_queue_arn
}
