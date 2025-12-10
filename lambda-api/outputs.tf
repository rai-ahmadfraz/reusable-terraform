# Lambda Function Outputs 
output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.lambda.function_name
}

#DynamoDB Outputs 
output "dynamodb_table_names" {
  description = "Names of the DynamoDB tables (if created)"
  value       = var.enable_dynamo ? [for t in aws_dynamodb_table.tables : t.name] : []
}

#conditional output for API Gateway URLs 
output "api_gateway_invoke_urls" {
  description = "Map of API Gateway URLs (if enabled)"
  value       = var.enable_api ? local.api_invoke_urls : {}
}

#Cognito Outputs 
output "cognito_user_pool_id" {
  value = var.enable_cognito ? aws_cognito_user_pool.this[0].id : null
  description = "Cognito User Pool ID"
}

output "cognito_user_pool_client_id" {
  value = var.enable_cognito ? aws_cognito_user_pool_client.this[0].id : null
  description = "Cognito App Client ID"
}

#SNS and SQS Outputs 
output "sns_topic_arn" {
  value       = var.enable_sns ? aws_sns_topic.this[0].arn : null
  description = "ARN of the SNS topic"
}

output "sqs_queue_url" {
  value       = var.enable_sqs ? aws_sqs_queue.this[0].url : null
  description = "URL of the SQS queue"
}

output "sqs_queue_arn" {
  value       = var.enable_sqs ? aws_sqs_queue.this[0].arn : null
  description = "ARN of the SQS queue"
}
