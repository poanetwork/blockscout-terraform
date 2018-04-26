variable "bootstrap" {
  description = "Whether we are bootstrapping the required infra or not"
  default     = 0
}

variable "bucket" {}
variable "dynamodb_table" {}
variable "prefix" {}
