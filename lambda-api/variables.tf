variable "lambda_name" { type = string }
variable "runtime"     { type = string }
variable "handler"     { type = string }
variable "package_path" { type = string }

variable "memory_size" {
  type    = number
  default = 256
}

variable "timeout" {
  type    = number
  default = 10
}

variable "env_vars" {
  type    = map(string)
  default = {}
}

# ------------------------
# FEATURE FLAGS
# ------------------------
variable "enable_api" {
  type    = bool
  default = true
}

variable "enable_dynamo" {
  type    = bool
  default = true
}

# ------------------------
# DYNAMODB
# ------------------------
variable "table_names" {
  type    = list(string)
  default = []
}

variable "partition_key" {
  type    = string
  default = "id"
}

# ------------------------
# API GATEWAY
# ------------------------
variable "endpoints" {
  type        = list(object({ method = string, path = string }))
  default     = []
}

variable "authorization" {
  type    = string
  default = "NONE"
}

variable "api_description" {
  type    = string
  default = "Serverless API"
}

variable "stage_name" {
  type    = string
  default = "prod"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "zip_hash" {
  description = "SHA256 hash of the Lambda zip to trigger redeploy"
  type        = string
  default     = ""
}

# COGNITO
variable "enable_cognito" {
  type    = bool
  default = false
}

variable "cognito_user_pool_name" {
  type    = string
  default = null
}

variable "cognito_app_client_name" {
  type    = string
  default = null
}


# SNS
variable "enable_sns" {
  type    = bool
  default = false
  description = "Whether to create SNS topic"
}

variable "sns_topic_name" {
  type    = string
  default = ""
  description = "SNS topic name"
}

# SQS
variable "enable_sqs" {
  type    = bool
  default = false
  description = "Whether to create SQS queue"
}

variable "sqs_queue_name" {
  type    = string
  default = ""
  description = "SQS queue name"
}
# SNS to SQS Subscription
variable "subscribe_sqs_to_sns" {
  type    = bool
  default = false
  description = "Whether to subscribe the SQS queue to the SNS topic"
}
