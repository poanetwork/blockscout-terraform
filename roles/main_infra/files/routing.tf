# Create a gateway to provide access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    prefix = var.prefix
    origin = "terraform"
  }
}

# Grant the VPC internet access in its main route table
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

# The ALB for the app server
resource "aws_lb" "explorer" {
  count              = length(var.chains)
  name               = "${var.prefix}-explorer-${element(var.chains, count.index)}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.default.id, aws_subnet.alb.id]

  enable_deletion_protection = false

  tags = {
    prefix = var.prefix
    origin = "terraform"
  }
}

# The Target Group for the ALB
resource "aws_lb_target_group" "explorer" {
  count    = length(var.chains)
  name     = "${var.prefix}-explorer-${element(var.chains, count.index)}-alb-target"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  tags = {
    prefix = var.prefix
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

resource "aws_alb_listener" "alb_listener" {
  count             = length(var.chains) 
  load_balancer_arn = aws_lb.explorer[count.index].arn
  port              = var.use_ssl[element(var.chains, count.index)] ? "443" : "80"
  protocol          = var.use_ssl[element(var.chains, count.index)] ? "HTTPS" : "HTTP"
  ssl_policy        = var.use_ssl[element(var.chains, count.index)] ? var.alb_ssl_policy[element(var.chains, count.index)] : null
  certificate_arn   = var.use_ssl[element(var.chains, count.index)] ? var.alb_certificate_arn[element(var.chains, count.index)] : null
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.explorer[count.index].arn
  }
}

