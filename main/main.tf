module "backend" {
  source = "../modules/backend"

  bootstrap      = "0"
  bucket         = "${var.bucket}"
  dynamodb_table = "${var.dynamodb_table}"
  prefix         = "${var.prefix}"
}

module "stack" {
  source = "../modules/stack"

  prefix                     = "${var.prefix}"
  region                     = "${var.region}"
  key_name                   = "${var.key_name}"
  chain_jsonrpc_variant      = "${var.chain_jsonrpc_variant}"
  chains                     = "${var.chains}"
  chain_trace_endpoint       = "${var.chain_trace_endpoint}"
  chain_ws_endpoint          = "${var.chain_ws_endpoint}"
  chain_logo                 = "${var.chain_logo}"
  chain_coin                 = "${var.chain_coin}"
  chain_network              = "${var.chain_network}"
  chain_subnetwork           = "${var.chain_subnetwork}"
  chain_network_path         = "${var.chain_network_path}"
  chain_network_icon         = "${var.chain_network_icon}"
  chain_graphiql_transaction = "${var.chain_graphiql_transaction}"
  chain_block_transformer    = "${var.chain_block_transformer}"


  vpc_cidr           = "${var.vpc_cidr}"
  public_subnet_cidr = "${var.public_subnet_cidr}"
  instance_type      = "${var.instance_type}"
  root_block_size    = "${var.root_block_size}"
  pool_size          = "${var.pool_size}"
  db_subnet_cidr     = "${var.db_subnet_cidr}"
  dns_zone_name      = "${var.dns_zone_name}"

  db_id             = "${var.db_id}"
  db_name           = "${var.db_name}"
  db_username       = "${var.db_username}"
  db_password       = "${var.db_password}"
  db_storage        = "${var.db_storage}"
  db_storage_type   = "${var.db_storage_type}"
  db_instance_class = "${var.db_instance_class}"

  secret_key_base       = "${var.secret_key_base}"
  new_relic_app_name    = "${var.new_relic_app_name}"
  new_relic_license_key = "${var.new_relic_license_key}"

  alb_ssl_policy      = "${var.alb_ssl_policy}"
  alb_certificate_arn = "${var.alb_certificate_arn}"
  use_ssl = "${var.use_ssl}"
}
