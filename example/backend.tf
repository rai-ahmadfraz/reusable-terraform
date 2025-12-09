terraform {
  backend "s3" {
    bucket         = "my-dynamic-bucket-applefn"
    key            = "serverless-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-applefn"
    encrypt        = true
  }
}
