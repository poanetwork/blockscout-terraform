resource "aws_ssm_parameter" "new_relic_app_name" {
  name  = "/${var.prefix}/${var.chain}/new_relic_app_name"
  value = "${var.new_relic_app_name}"
  type  = "String"
}

resource "aws_ssm_parameter" "new_relic_license_key" {
  name  = "/${var.prefix}/${var.chain}/new_relic_license_key"
  value = "${var.new_relic_license_key}"
  type  = "String"
}

resource "aws_ssm_parameter" "pool_size" {
  name  = "/${var.prefix}/${var.chain}/pool_size"
  value = "10"
  type  = "String"
}

resource "aws_ssm_parameter" "ecto_use_ssl" {
  name  = "/${var.prefix}/${var.chain}/ecto_use_ssl"
  value = "false"
  type  = "String"
}

resource "aws_ssm_parameter" "ethereum_jsonrpc_variant" {
  name  = "/${var.prefix}/${var.chain}/ethereum_jsonrpc_variant"
  value = "${var.chain_jsonrpc_variant}"
  type  = "String"
}
resource "aws_ssm_parameter" "ethereum_url" {
  name  = "/${var.prefix}/${var.chain}/ethereum_url"
  value = "${var.chain_ethereum_url}"
  type  = "String"
}

resource "aws_ssm_parameter" "trace_url" {
  name  = "/${var.prefix}/${var.chain}/trace_url"
  value = "${var.chain_trace_endpoint}"
  type  = "String"
}
resource "aws_ssm_parameter" "ws_url" {
  name  = "/${var.prefix}/${var.chain}/ws_url"
  value = "${var.chain_ws_endpoint}"
  type  = "String"
}

resource "aws_ssm_parameter" "logo" {
  name  = "/${var.prefix}/${var.chain}/logo"
  value = "${var.chain_logo}"
  type  = "String"
}

resource "aws_ssm_parameter" "check_origin" {
  name  = "/${var.prefix}/${var.chain}/check_origin"
  value = "${var.chain_check_origin}"
  type  = "String"
}

resource "aws_ssm_parameter" "coin" {
  name  = "/${var.prefix}/${var.chain}/coin"
  value = "${var.chain_coin}"
  type  = "String"
}

resource "aws_ssm_parameter" "network" {
  name  = "/${var.prefix}/${var.chain}/network"
  value = "${var.chain_network}"
  type  = "String"
}

resource "aws_ssm_parameter" "subnetwork" {
  name  = "/${var.prefix}/${var.chain}/subnetwork"
  value = "${var.chain_subnetwork}"
  type  = "String"
}

resource "aws_ssm_parameter" "network_path" {
  name  = "/${var.prefix}/${var.chain}/network_path"
  value = "${var.chain_network_path}"
  type  = "String"
}

resource "aws_ssm_parameter" "subnetwork_path" {
  name  = "/${var.prefix}/${var.chain}/subnetwork_path"
  value = "${var.chain_subnetwork_path}"
  type  = "String"
}

resource "aws_ssm_parameter" "network_icon" {
  name  = "/${var.prefix}/${var.chain}/network_icon"
  value = "${var.chain_network_icon}"
  type  = "String"
}

resource "aws_ssm_parameter" "exq_blocks_concurrency" {
  name  = "/${var.prefix}/${var.chain}/exq_blocks_concurrency"
  value = "1"
  type  = "String"
}

resource "aws_ssm_parameter" "exq_concurrency" {
  name  = "/${var.prefix}/${var.chain}/exq_concurrency"
  value = "1"
  type  = "String"
}

resource "aws_ssm_parameter" "exq_internal_transactions_concurrency" {
  name  = "/${var.prefix}/${var.chain}/exq_internal_transactions_concurrency"
  value = "1"
  type  = "String"
}

resource "aws_ssm_parameter" "exq_receipts_concurrency" {
  name  = "/${var.prefix}/${var.chain}/exq_receipts_concurrency"
  value = "1"
  type  = "String"
}

resource "aws_ssm_parameter" "exq_transactions_concurrency" {
  name  = "/${var.prefix}/${var.chain}/exq_transactions_concurrency"
  value = "1"
  type  = "String"
}

resource "aws_ssm_parameter" "secret_key_base" {
  name  = "/${var.prefix}/${var.chain}/secret_key_base"
  value = "${var.secret_key_base}"
  type  = "String"
}

resource "aws_ssm_parameter" "port" {
  name  = "/${var.prefix}/${var.chain}/port"
  value = "4000"
  type  = "String"
}

resource "aws_ssm_parameter" "db_username" {
  name  = "/${var.prefix}/${var.chain}/db_username"
  value = "${var.db_username}"
  type  = "String"
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.prefix}/${var.chain}/db_password"
  value = "${var.db_password}"
  type  = "String"
}

resource "aws_ssm_parameter" "db_host" {
  name  = "/${var.prefix}/${var.chain}/db_host"
  value = "${aws_route53_record.db.fqdn}"
  type  = "String"
}

resource "aws_ssm_parameter" "db_port" {
  name  = "/${var.prefix}/${var.chain}/db_port"
  value = "${aws_db_instance.default.port}"
  type  = "String"
}
resource "aws_ssm_parameter" "alb_ssl_policy" {
  name  = "/${var.prefix}/${var.chain}/alb_ssl_policy"
  value = "${var.alb_ssl_policy}"
  type  = "String"
}
resource "aws_ssm_parameter" "alb_certificate_arn" {
  name  = "/${var.prefix}/${var.chain}/alb_certificate_arn"
  value = "${var.alb_certificate_arn}"
  type  = "String"
}
