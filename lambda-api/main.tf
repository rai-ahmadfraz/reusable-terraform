terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ----------------------------------------------------------
# IAM ROLE for Lambda
# ----------------------------------------------------------
resource "aws_iam_role" "lambda_role" {
  name = substr("${var.lambda_name}-role", 0, 64)

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cw_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# DynamoDB Access Policy
resource "aws_iam_policy" "lambda_dynamo_policy" {
  name        = substr("${var.lambda_name}-dynamodb-policy", 0, 64)
  description = "DynamoDB access for Lambda"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ],
        Resource = var.table_arn != "" ? var.table_arn : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dynamo_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamo_policy.arn
}

# ----------------------------------------------------------
# DynamoDB Table (optional)
# ----------------------------------------------------------
resource "aws_dynamodb_table" "table" {
  count        = var.create_table ? 1 : 0
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.partition_key

  attribute {
    name = var.partition_key
    type = "S"
  }
}

# ----------------------------------------------------------
# Lambda Function
# ----------------------------------------------------------
resource "aws_lambda_function" "lambda" {
  function_name = var.lambda_name
  filename      = var.package_path
  handler       = var.handler
  runtime       = var.runtime
  role          = aws_iam_role.lambda_role.arn
  memory_size   = var.memory_size
  timeout       = var.timeout

  environment {
    variables = merge(var.env_vars, {
      DYNAMO_TABLE = var.create_table ? aws_dynamodb_table.table[0].name : var.table_name
    })
  }
}

# ----------------------------------------------------------
# API Gateway REST API
# ----------------------------------------------------------
resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.lambda_name}-api"
  description = var.api_description
}

# Sanitize path parts (remove "/")
locals {
  endpoints_map = {
    for ep in var.endpoints : ep.path => {
      path   = replace(ep.path, "/", "")
      method = ep.method
    }
  }
}

resource "aws_api_gateway_resource" "routes" {
  for_each    = local.endpoints_map
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = each.value.path
}

resource "aws_api_gateway_method" "methods" {
  for_each      = aws_api_gateway_resource.routes
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = each.value.id
  http_method   = upper(local.endpoints_map[each.key].method)
  authorization = var.authorization
}

resource "aws_api_gateway_integration" "integrations" {
  for_each                = aws_api_gateway_resource.routes
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = each.value.id
  http_method             = aws_api_gateway_method.methods[each.key].http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"

  # Correct API Gateway → Lambda URI
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda.arn}/invocations"
}

# ----------------------------------------------------------
# Lambda Permission (REQUIRED for trigger)
# ----------------------------------------------------------
resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# ----------------------------------------------------------
# Deployment
# ----------------------------------------------------------
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeploy = sha1(join(",", [
      for i in aws_api_gateway_integration.integrations : i.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.stage_name
  deployment_id = aws_api_gateway_deployment.deployment.id
}

# ----------------------------------------------------------
# Output API URLs
# ----------------------------------------------------------
locals {
  api_invoke_urls = {
    for ep in var.endpoints :
    ep.path => "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.stage_name}/${replace(ep.path, "/", "")}"
  }
}

output "api_urls" {
  value = local.api_invoke_urls
}
