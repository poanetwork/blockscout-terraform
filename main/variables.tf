variable "key_name" {
  description = "The name of the SSH key to use with EC2 hosts"
  default     = "poa"
}

variable "vpc_cidr" {
  description = "Virtual Private Cloud CIDR block"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
  default     = "10.0.0.0/24"
}

variable "db_subnet_cidr" {
  description = "The CIDR block for the database subnet"
  default     = "10.0.1.0/16"
}

variable "dns_zone_name" {
  description = "The internal DNS name"
  default     = "poa.internal"
}

variable "instance_type" {
  description = "The EC2 instance type to use for app servers"
  default     = "m5.xlarge"
}

variable "root_block_size" {
  description = "The EC2 instance root block size in GB"
  default     = 8
}

variable "chain" {
  description = "A map of chain names to urls"
  default = "sokol"
}

variable "chain_jsonrpc_variant" {
  description = "The chain JSON RPC variant"
  default = "parity"
}

variable "chain_ethereum_url" {
  description = "The base RPC endpoint for the chain"
  default = "https://sokol.poa.network"
}

variable "chain_trace_endpoint" {
  description = "A RPC tracing RPC endpoint"
  default = "https://sokol-trace.poa.network"
}

variable "chain_ws_endpoint" {
  description = "A Websocket RPC Endpoint for the chain"
  default = "wss://sokol-ws.poa.network/ws"
}

variable "chain_logo" {
  description = "The logo url for the chain"
  default = "/images/sokol_logo.svg"
}

variable "chain_check_origin" {
  description = "The chain names to the check_origin configuration"
  default = "false"
}

variable "chain_coin" {
  description = "The coin symbol"
  default = "POA"
}

variable "chain_network" {
  description = "The network name"
  default = "POA Network"
}

variable "chain_subnetwork" {
  description = "The subnetwork name"
  default = "Sokol Testnet"
}

variable "chain_network_path" {
  description = "The network name path"
  default = "poa"
}

variable "chain_subnetwork_path" {
  description = "The subnetwork name path"
  default = "sokol"
}

variable "chain_network_icon" {
  description = "The network navigation icon"
  default = "_test_network_icon.html"
}

# RDS/Database configuration
variable "db_id" {
  description = "The identifier for the RDS database"
  default     = "poa"
}

variable "db_name" {
  description = "The name of the database associated with the application"
  default     = "poa"
}

variable "db_username" {
  description = "The name of the user which will be used to connect to the database"
  default     = "poa"
}

variable "db_password" {
  description = "The password associated with the database user"
}

variable "db_storage" {
  description = "The database storage size in GB"
  default     = "100"
}

variable "db_storage_type" {
  description = "The type of database storage to use: magnetic, gp2, io1"
  default     = "gp2"
}

variable "db_instance_class" {
  description = "The instance class of the database"
  default     = "db.m4.large"
}

variable "secret_key_base" {
  description = "The secret key base to use for Explorer"
}

variable "new_relic_app_name" {
  description = "The name of the application in New Relic"
  default     = ""
}

variable "new_relic_license_key" {
  description = "The license key for talking to New Relic"
  default     = ""
}

# SSL Certificate configuration
variable "alb_ssl_policy" {
  description = "The SSL Policy for the Application Load Balancer"
  default     = ""
}

variable "alb_certificate_arn" {
  description = "The Certificate ARN for the Applicationn Load Balancer Policy"
  default     = ""
}
