resource "aws_ssm_parameter" "new_relic_app_name" {
  count = "${var.new_relic_app_name == "" ? 0 : length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/new_relic_app_name"
  value = "${var.new_relic_app_name}"
  type  = "String"
}

resource "aws_ssm_parameter" "new_relic_license_key" {
  count = "${var.new_relic_license_key == "" ? 0 : length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/new_relic_license_key"
  value = "${var.new_relic_license_key}"
  type  = "String"
}

resource "aws_ssm_parameter" "pool_size" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/pool_size"
  value = "10"
  type  = "String"
}

resource "aws_ssm_parameter" "ecto_use_ssl" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/ecto_use_ssl"
  value = "false"
  type  = "String"
}

resource "aws_ssm_parameter" "ethereum_url" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/ethereum_url"
  value = "${element(values(var.chains),count.index)}"
  type  = "String"
}

resource "aws_ssm_parameter" "trace_url" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chain_trace_endpoints),count.index)}/trace_url"
  value = "${element(values(var.chain_trace_endpoints), count.index)}"
  type  = "String"
}

resource "aws_ssm_parameter" "exq_blocks_concurrency" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/exq_blocks_concurrency"
  value = "1"
  type  = "String"
}

resource "aws_ssm_parameter" "exq_concurrency" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/exq_concurrency"
  value = "1"
  type  = "String"
}

resource "aws_ssm_parameter" "exq_internal_transactions_concurrency" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/exq_internal_transactions_concurrency"
  value = "1"
  type  = "String"
}

resource "aws_ssm_parameter" "exq_receipts_concurrency" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/exq_receipts_concurrency"
  value = "1"
  type  = "String"
}

resource "aws_ssm_parameter" "exq_transactions_concurrency" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/exq_transactions_concurrency"
  value = "1"
  type  = "String"
}

resource "aws_ssm_parameter" "secret_key_base" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/secret_key_base"
  value = "${var.secret_key_base}"
  type  = "String"
}

resource "aws_ssm_parameter" "port" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/port"
  value = "80"
  type  = "String"
}

resource "aws_ssm_parameter" "db_username" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/db_username"
  value = "${var.db_username}"
  type  = "String"
}

resource "aws_ssm_parameter" "db_password" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/db_password"
  value = "${var.db_password}"
  type  = "String"
}

resource "aws_ssm_parameter" "db_host" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/db_host"
  value = "${aws_route53_record.db.fqdn}"
  type  = "String"
}

resource "aws_ssm_parameter" "db_port" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/db_port"
  value = "${aws_db_instance.default.port}"
  type  = "String"
}
