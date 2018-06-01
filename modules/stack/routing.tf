# Create a gateway to provide access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    prefix = "${var.prefix}"
    origin = "terraform"
  }
}

# Grant the VPC internet access in its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# The ELB for the app server
resource "aws_elb" "explorer" {
  count = "${length(var.chains)}"
  name  = "${var.prefix}-explorer-${element(keys(var.chains),count.index)}-elb"

  subnets                     = ["${aws_subnet.default.id}"]
  security_groups             = ["${aws_security_group.elb.id}"]
  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 400

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"
  }

  listener {
    instance_port     = 4000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  #listener {
  #  instance_port      = 443
  #  instance_protocol  = "http"
  #  lb_port            = 443
  #  lb_protocol        = "https"
  #  ssl_certificate_id = "arn:aws:iam::ID:server-certificate/NAME"
  #}

  tags {
    prefix = "${var.prefix}"
    origin = "terraform"
  }
}

resource "aws_lb_cookie_stickiness_policy" "explorer" {
  count                    = "${length(var.chains)}"
  name                     = "${var.prefix}-explorer-${element(keys(var.chains),count.index)}-stickiness-policy"
  load_balancer            = "${aws_elb.explorer.*.id[count.index]}"
  lb_port                  = 80
  cookie_expiration_period = 600
}
