provider "aws" {
  #Temporary removed version check for local testing
  #version = "~> 2.17"
  profile = var.aws_profile
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region  = var.aws_region
}

