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
# IAM ROLE
# ----------------------------------------------------------
resource "aws_iam_role" "lambda_role" {
  name = substr("${var.lambda_name}-role", 0, 64)

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cw_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ----------------------------------------------------------
# DYNAMODB TABLES (multi-table support)
# ----------------------------------------------------------
resource "aws_dynamodb_table" "tables" {
  for_each     = var.enable_dynamo ? { for t in var.table_names : t => t } : {}
  name         = each.value
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.partition_key

  attribute {
    name = var.partition_key
    type = "S"
  }
}

resource "aws_iam_policy" "lambda_dynamo_policy" {
  count       = var.enable_dynamo && length(var.table_names) > 0 ? 1 : 0
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
        Resource = [for t in aws_dynamodb_table.tables : t.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dynamo_attach" {
  count      = var.enable_dynamo && length(var.table_names) > 0 ? 1 : 0
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamo_policy[0].arn
}

# ----------------------------------------------------------
# LAMBDA
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
    variables = merge(
      var.env_vars,
      var.enable_dynamo ? {
        DYNAMO_TABLES = join(",", [for t in aws_dynamodb_table.tables : t.name])
      } : {}
    )
  }
}

# ----------------------------------------------------------
# OPTIONAL: API GATEWAY
# ----------------------------------------------------------
resource "aws_api_gateway_rest_api" "api" {
  count       = var.enable_api ? 1 : 0
  name        = "${var.lambda_name}-api"
  description = var.api_description
}

locals {
  endpoints_map = {
    for ep in var.endpoints : ep.path => {
      path   = replace(ep.path, "/", "")
      method = ep.method
    }
  }

  api_invoke_urls = {
    for ep in var.endpoints :
    ep.path => var.enable_api ? "https://${aws_api_gateway_rest_api.api[0].id}.execute-api.${var.aws_region}.amazonaws.com/${var.stage_name}/${replace(ep.path, "/", "")}" : ""
  }
}

resource "aws_api_gateway_resource" "routes" {
  for_each    = var.enable_api ? local.endpoints_map : {}
  rest_api_id = aws_api_gateway_rest_api.api[0].id
  parent_id   = aws_api_gateway_rest_api.api[0].root_resource_id
  path_part   = each.value.path
}

resource "aws_api_gateway_method" "methods" {
  for_each      = var.enable_api ? aws_api_gateway_resource.routes : {}
  rest_api_id   = aws_api_gateway_rest_api.api[0].id
  resource_id   = each.value.id
  http_method   = upper(local.endpoints_map[each.key].method)
  authorization = var.authorization
}

resource "aws_api_gateway_integration" "integrations" {
  for_each                = var.enable_api ? aws_api_gateway_resource.routes : {}
  rest_api_id             = aws_api_gateway_rest_api.api[0].id
  resource_id             = each.value.id
  http_method             = aws_api_gateway_method.methods[each.key].http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"

  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda.arn}/invocations"
}

resource "aws_lambda_permission" "apigw_invoke" {
  count        = var.enable_api ? 1 : 0
  statement_id = "AllowAPIGatewayInvoke"
  action       = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api[0].execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "deployment" {
  count       = var.enable_api ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.api[0].id

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
  count         = var.enable_api ? 1 : 0
  rest_api_id   = aws_api_gateway_rest_api.api[0].id
  stage_name    = var.stage_name
  deployment_id = aws_api_gateway_deployment.deployment[0].id
}
