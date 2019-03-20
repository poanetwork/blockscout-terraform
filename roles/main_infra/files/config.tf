resource "aws_ssm_parameter" "elixir_version" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/elixir_version"
  value = "${var.elixir_version}"
  type  = "String"
}

resource "aws_ssm_parameter" "block_transformer" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/block_transformer"
  value = "${lookup(var.chain_block_transformer,element(keys(var.chains),count.index))}"
  type  = "String"
}

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
  value = "${lookup(var.chain_jsonrpc_variant,element(keys(var.chains),count.index))}"
  type  = "String"
}
resource "aws_ssm_parameter" "ethereum_url" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/ethereum_jsonrpc_http_url"
  value = "${element(values(var.chains),count.index)}"
  type  = "String"
}

resource "aws_ssm_parameter" "trace_url" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/ethereum_jsonrpc_trace_url"
  value = "${lookup(var.chain_trace_endpoint,element(keys(var.chains),count.index))}"
  type  = "String"
}
resource "aws_ssm_parameter" "ws_url" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/ethereum_jsonrpc_ws_url"
  value = "${lookup(var.chain_ws_endpoint,element(keys(var.chains),count.index))}" 
  type  = "String"
}

resource "aws_ssm_parameter" "logo" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/logo"
  value = "${lookup(var.chain_logo,element(keys(var.chains),count.index))}"
  type  = "String"
}

resource "aws_ssm_parameter" "coin" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/coin"
  value = "${lookup(var.chain_coin,element(keys(var.chains),count.index))}" 
  type  = "String"
}

resource "aws_ssm_parameter" "network" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/network"
  value = "${lookup(var.chain_network,element(keys(var.chains),count.index))}"
  type  = "String"
}

resource "aws_ssm_parameter" "subnetwork" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/subnetwork"
  value = "${lookup(var.chain_subnetwork,element(keys(var.chains),count.index))}" 
  type  = "String"
}

resource "aws_ssm_parameter" "network_path" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/network_path"
  value = "${lookup(var.chain_network_path,element(keys(var.chains),count.index))}"
  type  = "String"
}

resource "aws_ssm_parameter" "network_icon" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/network_icon"
  value = "${lookup(var.chain_network_icon,element(keys(var.chains),count.index))}" 
  type  = "String"
}

resource "aws_ssm_parameter" "graphiql_transaction" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/graphiql_transaction"
  value = "${lookup(var.chain_graphiql_transaction,element(keys(var.chains),count.index))}"
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
  value = "${lookup(var.chain_db_username,element(keys(var.chains),count.index))}"
  type  = "String"
}

resource "aws_ssm_parameter" "db_password" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/db_password"
  value = "${lookup(var.chain_db_password,element(keys(var.chains),count.index))}"
  type  = "String"
}

resource "aws_ssm_parameter" "db_host" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/db_host"
  value = "${aws_route53_record.db.*.fqdn[count.index]}"
  type  = "String"
}

resource "aws_ssm_parameter" "db_port" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/db_port"
  value = "${aws_db_instance.default.*.port[count.index]}"
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
resource "aws_ssm_parameter" "heart_beat_timeout" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/heart_beat_timeout"
  value = "${lookup(var.chain_heart_beat_timeout,element(keys(var.chains),count.index))}"
  type  = "String"
}

resource "aws_ssm_parameter" "heart_command" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/heart_command"
  value = "${lookup(var.chain_heart_command,element(keys(var.chains),count.index))}"
  type  = "String"
}

resource "aws_ssm_parameter" "blockscout_version" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/blockscout_version"
  value = "${lookup(var.chain_blockscout_version,element(keys(var.chains),count.index))}"
  type  = "String"
}

resource "aws_ssm_parameter" "db_name" {
  count = "${length(var.chains)}"
  name  = "/${var.prefix}/${element(keys(var.chains),count.index)}/db_name"
  value = "${lookup(var.chain_db_name,element(keys(var.chains),count.index))}"
  type  = "String"
}
