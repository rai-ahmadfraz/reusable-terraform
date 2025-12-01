variable "aws_region" { default = "us-east-1" }

provider "aws" {
  region = var.aws_region
}
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../example/lambda"
  output_path = "${path.module}/../example/lambda.zip"
  excludes = [
    "**/node_modules/*",
    "**/*.log",
    "**/.terraform/*",
    "**/*.zip"
  ]
}
module "serverless_app" {
  source = "../lambda-api"

  lambda_name   = "sample-function9"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  package_path  = data.archive_file.lambda_zip.output_path
  table_name    = "sample-table9"
  partition_key = "id"
  aws_region    = var.aws_region

  endpoints = [
    { method = "POST", path = "create" },
    { method = "GET",  path = "list" },
    { method = "DELETE", path = "delete" }
  ]
}


