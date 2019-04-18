variable "region" {}
variable "prefix" {}
variable "key_name" {}
variable "vpc_cidr" {}
variable "public_subnet_cidr" {}
variable "db_subnet_cidr" {}
variable "dns_zone_name" {}
variable "instance_type" {}
variable "root_block_size" {}
variable "pool_size" {
  default = {} 
}
variable "elixir_version" {}
variable "use_placement_group" {
  default = {}
}
variable "key_content" {
  default = ""
}

variable "chains" {
  default = []
}

variable "chain_db_id" {
  default = {}
}

variable "chain_db_name" {
  default = {}
}

variable "chain_db_username" {
  default = {}
}

variable "chain_db_password" {
  default = {}
}

variable "chain_db_storage" {
  default = {}
}

variable "chain_db_storage_type" {
  default = {}
}

variable "chain_db_iops" {
  default = {}
}

variable "chain_db_instance_class" {
  default = {}
}

variable "chain_db_version" {
  default = {}
}

variable "secret_key_base" {
  default = {} 
}

variable "alb_ssl_policy" {
  default = {}
}

variable "alb_certificate_arn" {
  default = {}
}

variable "use_ssl" {
  default = {} 
}
