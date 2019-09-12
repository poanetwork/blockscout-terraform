resource "aws_ssm_parameter" "db_host" {
  count = length(var.chains)
  name  = "/${var.prefix}/${element(var.chains, count.index)}/db_host"
  value = aws_route53_record.db[count.index].fqdn
  type  = "String"
}

resource "aws_ssm_parameter" "db_host_read" {
  count = length(var.chains)
  name  = "/${var.prefix}/${var.chains[count.index]}/db_host_read"
  value = aws_route53_record.db_reader[count.index].fqdn
  type  = "String"
}

resource "aws_ssm_parameter" "db_port" {
  count = length(var.chains)
  name  = "/${var.prefix}/${element(var.chains, count.index)}/db_port"
  value = aws_rds_cluster.postgresql[count.index].port
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

resource "aws_rds_cluster" "postgresql" {
  count                   = length(var.chains)
  cluster_identifier      = "${var.prefix}-${var.chain_db_id[element(var.chains, count.index)]}"
  engine                  = "aurora-postgresql"
  engine_version          = var.chain_db_version[element(var.chains, count.index)]
  availability_zones      = data.aws_availability_zones.available.names
  database_name           = var.chain_db_name[element(var.chains, count.index)]
  master_username         = var.chain_db_username[element(var.chains, count.index)]
  master_password         = var.chain_db_password[element(var.chains, count.index)]
  vpc_security_group_ids  = [aws_security_group.database.id] 
  copy_tags_to_snapshot   = true
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.database.id
  apply_immediately       = true

  depends_on = [aws_security_group.database]

  tags = {
    prefix = var.prefix
    origin = "terraform"
  }
}

resource "aws_rds_cluster_instance" "instance" {
  count                = length(var.chain_db_readers)
  identifier           = "${var.prefix}-${var.chain_db_readers[count.index]}-${count.index}"
  cluster_identifier   = "${var.prefix}-${var.chain_db_id[var.chain_db_readers[count.index]]}"
  instance_class       = var.chain_db_instance_class[element(var.chains, count.index)]
  db_subnet_group_name = aws_db_subnet_group.database.id
}
