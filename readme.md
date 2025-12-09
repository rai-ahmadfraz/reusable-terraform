# Reusable Terraform Module

This project demonstrates how to deploy a **serverless Lambda function** with optional **DynamoDB tables** and **API Gateway endpoints** using Terraform. It also supports **remote state management** using **S3** and **DynamoDB** for locking.  

---

## Prerequisites

- **Terraform** ≥ 5.0.0  
- **AWS CLI** configured with valid credentials  
- **Node.js** (for Lambda function development)  
- Linux/Mac terminal or WSL for running shell scripts  

---

## Project Structure
    example/
    ├─ lambda/ # Lambda source code
    │ └─ index.js
    ├─ main.tf # Root Terraform configuration
    ├─ backend.tf # Terraform backend configuration
    ├─ create-backend.sh # Script to create S3 bucket & DynamoDB lock table

    lambda-api/ # Terraform module for Lambda + API + DynamoDB
    ├─ main.tf
    ├─ variables.tf
    ├─ api.tf
    ├─ dynamo.tf
    ├─ iam.tf
    ├─ lambda.tf
    └─ outputs.tf



---

## 1. Creating the Terraform Backend

Before initializing Terraform, you must create the S3 bucket and DynamoDB table for remote state storage.  

**Important:**  

When creating a new Lambda function, make sure to **update all resource names** to avoid conflicts. This includes:

- Lambda function name  
- DynamoDB table names  
- S3 bucket name for Terraform state  
- DynamoDB table name used for Terraform state locking  

Also, ensure that **all resources are created in the same AWS region** in the following files:  

- `create-backend.sh`  
- `backend.tf`  
- `main.tf`  

This prevents naming collisions and ensures Terraform can properly manage remote state and locks.

---

## 2. First-Time Deployment

For the very first deployment, run the backend creation script. This will create all necessary resources and deploy your Lambda function automatically:

<!-- ```bash -->
chmod +x create-backend.sh
./create-backend.sh

## 3. Subsequent Deployments

After the initial setup, you can manage and update your infrastructure with the standard Terraform workflow:

<!-- ```bash -->
terraform init
terraform plan
terraform apply

Terraform will automatically detect changes in your Lambda source code and redeploy the function if necessary.



## Notes

- Always ensure that **bucket names and DynamoDB table names are unique** for each new Lambda project.  
- Make sure to use the **same AWS region** for all resources to prevent conflicts.  
- The module supports **multiple DynamoDB tables** and **API Gateway endpoints**, making it reusable for different Lambda functions.
