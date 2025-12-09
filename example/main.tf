variable "aws_region" { default = "us-east-1" }

provider "aws" {
  region = var.aws_region
}
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../example/lambda"
  output_path = "${path.module}/../example/lambda.zip"
}

module "serverless_app" {
  source = "../lambda-api"
  # source = "git::https://github.com/rai-ahmadfraz/reusable-terraform.git//lambda-api?ref=main"
  lambda_name   = "example"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  package_path  = data.archive_file.lambda_zip.output_path
  partition_key = "id"
  aws_region    = var.aws_region

  enable_dynamo  = true
  table_names    = ["exampletable1", "exampletable2"]
  zip_hash = filesha256(data.archive_file.lambda_zip.output_path)
  enable_api     = true
  endpoints = [
    { method = "POST", path = "create" },
    { method = "GET",  path = "list" },
    { method = "DELETE", path = "delete" }
  ]
}
