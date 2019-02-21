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

variable "pool_size" {
  description = "The number of connections available to the RDS instance"
  default     = 30
}

variable "chains" {
  description = "A map of chain names to urls"
  default = {
    "sokol" = "https://sokol-trace.poa.network"
  }
}

variable "chain_trace_endpoint" {
  description = "A map of chain names to RPC tracing endpoint"
  default = {
    "sokol" = "https://sokol-trace.poa.network"
  }
}

variable "chain_ws_endpoint" {
  description = "A map of chain names to Websocket RPC Endpoint"
  default = {
    "sokol" = "wss://sokol-ws.poa.network/ws"
  }
}

variable "chain_jsonrpc_variant" {
  description = "A map of chain names to JSON RPC variant"
  default = {
    "sokol" = "parity"
  }
}

variable "chain_logo" {
  description = "A map of chain names to logo url"
  default = {
    "sokol" = "/images/sokol_logo.svg"
  }
}

variable "chain_coin" {
  description = "A map of chain name to coin symbol"
  default = {
    "sokol" = "POA"
  }
}

variable "chain_network" {
  description = "A map of chain names to network name"
  default = {
    "sokol" = "POA Network"
  }
}

variable "chain_subnetwork" {
  description = "A map of chain names to subnetwork name"
  default = {
    "sokol" = "Sokol Testnet"
  }
}

variable "chain_network_path" {
  description = "A map of chain names to network name path"
  default = {
    "sokol" = "/poa/sokol"
  }
}

variable "chain_network_icon" {
  description = "A map of chain names to network navigation icon"
  default = {
    "sokol" = "_test_network_icon.html"
  }
}
variable "chain_block_transformer" {
  description = "A map of chain names to block transformer algo"
  default = {
    "sokol" = "base"
  }
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
  default     = "ELBSecurityPolicy-2016-08"
}

variable "alb_certificate_arn" {
  description = "The Certificate ARN for the Applicationn Load Balancer Policy"
  default     = "arn:aws:acm:us-east-1:008312654217:certificate/ce6ec2cb-eba4-4b02-af1d-e77ce8813497"
}

variable "use_ssl" {
  description = "Enable SSL"
  default = "true"
}