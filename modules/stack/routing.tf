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

# The ALB for the app server
resource "aws_lb" "explorer" {
  count              = "${length(var.chains)}"
  name               = "${var.prefix}-explorer-${element(keys(var.chains),count.index)}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.alb.id}"]
  subnets            = ["${aws_subnet.default.id}", "${aws_subnet.alb.id}"]

  enable_deletion_protection = false

  tags {
    prefix = "${var.prefix}"
    origin = "terraform"
  }
}

# The Target Group for the ALB
resource "aws_lb_target_group" "explorer" {
  count    = "${length(var.chains)}"
  name     = "${var.prefix}-explorer-${element(keys(var.chains),count.index)}-alb-target"
  port     = 4000  
  protocol = "HTTP"  
  vpc_id   = "${aws_vpc.vpc.id}"   
  tags {
    prefix = "${var.prefix}"
    origin = "terraform"
  }   
  stickiness {    
    type            = "lb_cookie"
    cookie_duration = 600    
    enabled         = true  
  }   
  health_check {    
    healthy_threshold   = 2    
    unhealthy_threshold = 2    
    timeout             = 15    
    interval            = 30    
    path                = "/blocks"    
    port                = 4000  
  }
}

# The Listener for the ALB
resource "aws_alb_listener" "alb_listener" {  
  load_balancer_arn = "${aws_lb.explorer.arn}"  
  port              = 443  
  protocol          = "HTTPS"
  ssl_policy        = "${var.alb_ssl_policy}"
  certificate_arn   = "${var.alb_certificate_arn}"
  
  default_action {    
    target_group_arn = "${aws_lb_target_group.explorer.arn}"
    type             = "forward"  
  }
}
