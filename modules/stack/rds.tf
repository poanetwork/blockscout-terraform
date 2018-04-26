resource "aws_db_instance" "default" {
  identifier             = "${var.prefix}-${var.db_id}"
  engine                 = "postgres"
  engine_version         = "9.6"
  instance_class         = "${var.db_instance_class}"
  storage_type           = "${var.db_storage_type}"
  allocated_storage      = "${var.db_storage}"
  copy_tags_to_snapshot  = true
  skip_final_snapshot    = true
  username               = "${var.db_username}"
  password               = "${var.db_password}"
  vpc_security_group_ids = ["${aws_security_group.database.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.database.id}"

  depends_on = ["aws_security_group.database"]

  tags {
    prefix = "${var.prefix}"
    origin = "terraform"
  }
}
