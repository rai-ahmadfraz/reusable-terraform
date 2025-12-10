#Always change bucket name, dynamodb table name while creating new lambda function to avoid conflicts
# Use same region as used in main.tf for creating s3 bucket and dynamodb table
terraform {
  backend "s3" {
    bucket         = "my-dynamic-bucket-example1" #replace with your bucket name/ lambda whenever new lambda is created
    key            = "serverless-app/terraform.tfstate"
    region         = "us-east-1" #region should be same as used in main.tf
    dynamodb_table = "terraform-locks-example1" #replace with your bucket name/ lambda whenever new lambda is created
    encrypt        = true
  }
}
