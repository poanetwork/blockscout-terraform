variable "region" {}
variable "prefix" {}
variable "key_name" {}
variable "vpc_cidr" {}
variable "public_subnet_cidr" {}
variable "db_subnet_cidr" {}
variable "dns_zone_name" {}
variable "instance_type" {}
variable "root_block_size" {}
variable "pool_size" {}

variable "key_content" {
  default = ""
}

variable "chain_jsonrpc_variant" {
  default = {}
}
variable "chains" {
  default = {}
}
variable "chain_trace_endpoint" {
  default = {}
}
variable "chain_ws_endpoint" {
  default = {}
}
variable "chain_logo" {
  default = {}
}
variable "chain_coin" {
  default = {}
}
variable "chain_network" {
  default = {}
}
variable "chain_subnetwork" {
  default = {}
}
variable "chain_network_path" {
  default = {}
}
variable "chain_network_icon" {
  default = {}
}

variable "db_id" {}
variable "db_username" {}
variable "db_password" {}
variable "db_storage" {}
variable "db_storage_type" {}
variable "db_instance_class" {}
variable "db_version" {}

variable "new_relic_app_name" {}
variable "new_relic_license_key" {}
variable "secret_key_base" {}
variable "alb_ssl_policy" {}
variable "alb_certificate_arn" {}
variable "use_ssl" {}

variable "chain_graphiql_transaction" {
  default = {}
}

variable "chain_block_transformer" {
  default = {}
}

variable "chain_heart_beat_timeout" {
  default = {}
}

variable "chain_heart_command" {
  default = {}
}

variable "chain_blockscout_version" {
  default = {}
}
