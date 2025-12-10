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
  lambda_name   = "example1"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  package_path  = data.archive_file.lambda_zip.output_path
  partition_key = "id"
  aws_region    = var.aws_region
  stage_name = "rai"
  enable_dynamo  = true
  table_names    = ["exampletable11", "exampletable22"]
  zip_hash = filesha256(data.archive_file.lambda_zip.output_path)
  enable_api     = true
  endpoints = [
    { method = "POST", path = "create" },
    { method = "GET",  path = "list" },
    { method = "DELETE", path = "delete" }
  ]
  # Enable Cognito
  enable_cognito           = true
  cognito_user_pool_name   = "example1-user-pool"
  cognito_app_client_name  = "example1-app-client"

  #SNS
  enable_sns  = true
  sns_topic_name = "example1-topic"

  #SQS
  enable_sqs  = true
  sqs_queue_name = "example1-queue"

  # Subscribe SQS to SNS Topic
  subscribe_sqs_to_sns = true
}
