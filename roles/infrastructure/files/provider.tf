provider "aws" {
  # 2.42 is required for advanced ALB support
  version = "~> 2.42"
  profile = var.aws_profile
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region  = var.aws_region
}

