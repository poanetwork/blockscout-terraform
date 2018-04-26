variable "bucket" {
  description = "The name of the S3 bucket which will hold Terraform state"
}

variable "dynamodb_table" {
  description = "The name of the DynamoDB table which will hold Terraform locks"
}

variable "region" {
  description = "The AWS region to use"
  default     = "us-east-2"
}

variable "prefix" {
  description = "The prefix used to identify all resources generated with this plan"
}
