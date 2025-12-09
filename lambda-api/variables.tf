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
