module "backend" {
  source = "../modules/backend"

  bootstrap      = "${terraform.workspace == "base" ? 1 : 0}"
  bucket         = "${var.bucket}"
  dynamodb_table = "${var.dynamodb_table}"
  prefix         = "${var.prefix}"
}
