resource "aws_ssm_parameter" "db_host" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/db_host"
  value = "${aws_route53_record.db.*.fqdn[count.index]}"
  type  = "String"
}

resource "aws_db_instance" "default" {
  count                  = "${length(var.chains)}"
  name                   = "${lookup(var.chain_db_name,element(keys(var.chains),count.index))}"
  identifier             = "${var.prefix}-${lookup(var.chain_db_id,element(keys(var.chains),count.index))}"
  engine                 = "postgres"
  engine_version         = "${lookup(var.chain_db_version,element(keys(var.chains),count.index))}"
  instance_class         = "${lookup(var.chain_db_instance_class,element(keys(var.chains),count.index))}"
  storage_type           = "${lookup(var.chain_db_storage_type,element(keys(var.chains),count.index))}"
  allocated_storage      = "${lookup(var.chain_db_storage,element(keys(var.chains),count.index))}"
  copy_tags_to_snapshot  = true
  skip_final_snapshot    = true
  username               = "${lookup(var.chain_db_username,element(keys(var.chains),count.index))}"
  password               = "${lookup(var.chain_db_password,element(keys(var.chains),count.index))}"
  vpc_security_group_ids = ["${aws_security_group.database.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.database.id}"
  apply_immediately      = true
  iops                   = "${lookup(var.chain_db_iops,element(keys(var.chains),count.index),"0")}"


  depends_on = ["aws_security_group.database"]

  tags {
    prefix = "${var.prefix}"
    origin = "terraform"
  }
}
