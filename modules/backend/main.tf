# S3 bucket
resource "aws_s3_bucket" "terraform_state" {
  count = "${var.bootstrap}"

  bucket = "${var.prefix}-${var.bucket}"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "expire"
    enabled = true

    noncurrent_version_expiration {
      days = 90
    }
  }

  tags {
    origin = "terraform"
    prefix = "${var.prefix}"
  }
}

# DynamoDB table
resource "aws_dynamodb_table" "terraform_statelock" {
  count = "${var.bootstrap}"

  name           = "${var.prefix}-${var.dynamodb_table}"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    origin = "terraform"
    prefix = "${var.prefix}"
  }
}
