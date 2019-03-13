# This module will create the VPC for POA
# It is composed of:
#   - VPC
#   - Security group for VPC
#   - A public subnet
#   - A private subnet
#   - NAT to give the private subnet access to internet

data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name   = "${var.prefix}"
    prefix = "${var.prefix}"
    origin = "terraform"
  }
}

resource "aws_vpc_dhcp_options" "poa_dhcp" {
  domain_name         = "${var.dns_zone_name}"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags {
    prefix = "${var.prefix}"
    origin = "terraform"
  }
}

resource "aws_vpc_dhcp_options_association" "poa_dhcp" {
  vpc_id          = "${aws_vpc.vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.poa_dhcp.id}"
}
