# DYNAMODB TABLES
resource "aws_dynamodb_table" "tables" {
  for_each     = var.enable_dynamo ? { for t in var.table_names : t => t } : {}
  name         = each.value
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.partition_key

  attribute {
    name = var.partition_key
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# DynamoDB -> Lambda IAM Policy
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
