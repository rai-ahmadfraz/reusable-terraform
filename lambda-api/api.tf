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
    ep.path => var.enable_api ?
      "https://${aws_api_gateway_rest_api.api[0].id}.execute-api.${var.aws_region}.amazonaws.com/${var.stage_name}/${replace(ep.path, "/", "")}"
      : ""
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
