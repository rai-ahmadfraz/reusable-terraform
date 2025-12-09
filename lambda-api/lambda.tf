resource "aws_lambda_function" "lambda" {
  function_name = var.lambda_name
  filename      = var.package_path
  handler       = var.handler
  runtime       = var.runtime
  role          = aws_iam_role.lambda_role.arn
  memory_size   = var.memory_size
  timeout       = var.timeout

  environment {
    variables = merge(
      var.env_vars,
      var.enable_dynamo ? {
        DYNAMO_TABLES = join(",", [for t in aws_dynamodb_table.tables : t.name])
      } : {}
    )
  }
}
