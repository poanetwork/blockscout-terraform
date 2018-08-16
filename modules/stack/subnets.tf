## Public subnet

resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.public_subnet_cidr}"
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"
  map_public_ip_on_launch = true

  tags {
    name   = "${var.prefix}-default-subnet"
    prefix = "${var.prefix}"
    origin = "terraform"
  }
}

## ALB subnet
resource "aws_subnet" "alb" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.public_subnet_cidr}"
  cidr_block              = "${cidrsubnet(var.db_subnet_cidr, 5, 1)}"
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"
  map_public_ip_on_launch = true

  tags {
    name   = "${var.prefix}-default-subnet"
    prefix = "${var.prefix}"
    origin = "terraform"
  }
}

## Database subnet
resource "aws_subnet" "database" {
  count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet(var.db_subnet_cidr, 8, 1 + count.index)}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = false

  tags {
    name   = "${var.prefix}-database-subnet${count.index}"
    prefix = "${var.prefix}"
    origin = "terraform"
  }
}

resource "aws_db_subnet_group" "database" {
  name        = "${var.prefix}-database"
  description = "The group of database subnets"
  subnet_ids  = ["${aws_subnet.database.*.id}"]

  tags {
    prefix = "${var.prefix}"
    origin = "terraform"
  }
}
