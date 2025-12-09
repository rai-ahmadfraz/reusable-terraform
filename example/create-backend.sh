#Always change bucket name, dynamodb table name while creating new lambda function to avoid conflicts
#use same region in backend.tf and while creating s3 bucket and dynamodb table

aws s3api create-bucket --bucket my-dynamic-bucket-example  --region us-east-1

aws dynamodb create-table \
  --table-name terraform-locks-example \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

terraform init
terraform plan
terraform apply

# chmod +x create-backend.sh && ./create-backend.sh 

