provider "aws" {
  region     = "us-west-2"
}
resource "aws_s3_bucket" "state_backend" {
  bucket = "my-tf-state-S3-bucket"

  lifecycle {
    prevent_destroy = false
  }
                                    
  }
  resource "aws_dynamodb_table" "dynamodb_locking_state" {
  name           = "terraform_eks_state_locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "lockID"
 

  attribute {
    name = "lockID"
    type = "S"
  }

  }
  
  