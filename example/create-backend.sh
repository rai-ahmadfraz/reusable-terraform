aws s3api create-bucket --bucket my-dynamic-bucket-applefn --region us-east-1

aws dynamodb create-table \
  --table-name terraform-locks-applefn \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

terraform init
terraform plan
terraform apply

# chmod +x create-backend.sh && ./create-backend.sh 
# chmod +x deploy.sh
# ./deploy.sh

