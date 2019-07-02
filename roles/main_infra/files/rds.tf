resource "aws_ssm_parameter" "db_host" {
  count = length(var.chains)
  name  = "/${var.prefix}/${element(var.chains, count.index)}/db_host"
  value = aws_route53_record.db[count.index].fqdn
  type  = "String"
}

resource "aws_ssm_parameter" "db_port" {
  count = length(var.chains)
  name  = "/${var.prefix}/${element(var.chains, count.index)}/db_port"
  value = aws_db_instance.default[count.index].port
  type  = "String"
}

resource "aws_ssm_parameter" "db_name" {
  count = length(var.chains)
  name  = "/${var.prefix}/${element(var.chains, count.index)}/db_name"
  value = var.chain_db_name[element(var.chains, count.index)]
  type  = "String"
}

resource "aws_ssm_parameter" "db_username" {
  count = length(var.chains)
  name  = "/${var.prefix}/${element(var.chains, count.index)}/db_username"
  value = var.chain_db_username[element(var.chains, count.index)]
  type  = "String"
}

resource "aws_ssm_parameter" "db_password" {
  count = length(var.chains)
  name  = "/${var.prefix}/${element(var.chains, count.index)}/db_password"
  value = var.chain_db_password[element(var.chains, count.index)]
  type  = "String"
}

resource "aws_db_instance" "default" {
  count                  = length(var.chains)
  name                   = var.chain_db_name[element(var.chains, count.index)]
  identifier             = "${var.prefix}-${var.chain_db_id[element(var.chains, count.index)]}"
  engine                 = "postgres"
  engine_version         = var.chain_db_version[element(var.chains, count.index)]
  instance_class         = var.chain_db_instance_class[element(var.chains, count.index)]
  storage_type           = var.chain_db_storage_type[element(var.chains, count.index)]
  allocated_storage      = var.chain_db_storage[element(var.chains, count.index)]
  copy_tags_to_snapshot  = true
  skip_final_snapshot    = true
  username               = var.chain_db_username[element(var.chains, count.index)]
  password               = var.chain_db_password[element(var.chains, count.index)]
  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = aws_db_subnet_group.database.id
  apply_immediately      = true
  iops                   = lookup(var.chain_db_iops, element(var.chains, count.index), "0")

  depends_on = [aws_security_group.database]

  tags = {
    prefix = var.prefix
    origin = "terraform"
  }
}

