resource "aws_s3_bucket" "explorer_releases" {
  bucket        = "${var.prefix}-explorer-codedeploy-releases"
  acl           = "private"
  force_destroy = "true"

  versioning {
    enabled = true
  }
}

resource "aws_codedeploy_app" "explorer" {
  name = "${var.prefix}-explorer"
}
