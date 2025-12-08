output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.lambda.function_name
}

output "dynamodb_table_names" {
  description = "Names of the DynamoDB tables (if created)"
  value       = var.enable_dynamo ? [for t in aws_dynamodb_table.tables : t.name] : []
}

output "api_gateway_invoke_urls" {
  description = "Map of API Gateway URLs (if enabled)"
  value       = var.enable_api ? local.api_invoke_urls : {}
}
