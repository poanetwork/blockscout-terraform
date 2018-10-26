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
  value = "${var.pool_size}"
  type  = "String"
}

resource "aws_ssm_parameter" "ecto_use_ssl" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/ecto_use_ssl"
  value = "false"
  type  = "String"
}

resource "aws_ssm_parameter" "ethereum_jsonrpc_variant" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/ethereum_jsonrpc_variant"
  value = "${element(values(var.chain_jsonrpc_variant),count.index)}"
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
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/trace_url"
  value = "${element(values(var.chain_trace_endpoint),count.index)}"
  type  = "String"
}
resource "aws_ssm_parameter" "ws_url" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/ws_url"
  value = "${element(values(var.chain_ws_endpoint),count.index)}"
  type  = "String"
}

resource "aws_ssm_parameter" "logo" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/logo"
  value = "${element(values(var.chain_logo),count.index)}"
  type  = "String"
}

resource "aws_ssm_parameter" "coin" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/coin"
  value = "${element(values(var.chain_coin),count.index)}"
  type  = "String"
}

resource "aws_ssm_parameter" "network" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/network"
  value = "${element(values(var.chain_network),count.index)}"
  type  = "String"
}

resource "aws_ssm_parameter" "subnetwork" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/subnetwork"
  value = "${element(values(var.chain_subnetwork),count.index)}"
  type  = "String"
}

resource "aws_ssm_parameter" "network_path" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/network_path"
  value = "${element(values(var.chain_network_path),count.index)}"
  type  = "String"
}

resource "aws_ssm_parameter" "network_icon" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/network_icon"
  value = "${element(values(var.chain_network_icon),count.index)}"
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
  value = "4000"
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
resource "aws_ssm_parameter" "alb_ssl_policy" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/alb_ssl_policy"
  value = "${var.alb_ssl_policy}"
  type  = "String"
}
resource "aws_ssm_parameter" "alb_certificate_arn" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/alb_certificate_arn"
  value = "${var.alb_certificate_arn}"
  type  = "String"
}
