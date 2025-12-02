output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.lambda.function_name
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table (if created)"
  value       = var.enable_dynamo && var.create_table ? aws_dynamodb_table.table[0].name : null
}

output "api_gateway_invoke_urls" {
  description = "Map of API Gateway URLs (if enabled)"
  value       = var.enable_api ? local.api_invoke_urls : {}
}
