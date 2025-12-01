# Lambda Function Name
output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.lambda.function_name
}

# DynamoDB Table Name (only if created)
output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = var.create_table ? aws_dynamodb_table.table[0].name : var.table_name
}

# API Gateway Invoke URLs
output "api_gateway_invoke_urls" {
  description = "Map of API Gateway URLs for each endpoint"
  value       = local.api_invoke_urls
}
