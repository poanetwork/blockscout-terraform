# The Target Group for the ALB
resource "aws_lb_target_group" "common" {
  count    = var.instance_number > 0 ? 1 : 0
  name     = "${var.prefix}-${var.type}-${var.chain}-bs-tg"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = var.aws_vpc
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

resource "aws_lb_listener_rule" "regular" {
  count        = var.instance_number > 0 ? var.instance_type == "regular" ? 1 : 0 : 0
  listener_arn = var.alb_listener
  priority     = "7"

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.common[0].arn
  }

  condition {
    path_pattern = ["/*"]
  }
}

resource "aws_lb_listener_rule" "verify_api" {
  count        = var.instance_number > 0 ? var.instance_type == "web" ? 1 : 0 : 0
  listener_arn = var.alb_listener
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.common[0].arn
  }

  condition {
    query_string {
      key   = "action"
      value = "verify"
    }
  }
}

resource "aws_lb_listener_rule" "eth_block_number_api" {
  count        = var.instance_number > 0 ? var.instance_type == "web" ? 1 : 0 : 0
  listener_arn = var.alb_listener
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.common[0].arn
  }

  condition {
    query_string {
      key   = "action"
      value = "eth_block_number"
    }
  }
}

resource "aws_lb_listener_rule" "api_ethrpc" {
  count        = var.instance_number > 0 ? var.instance_type == "api" ? 1 : 0 : 0
  listener_arn = var.alb_listener
  priority     = 3

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.common[0].arn
  }

  condition {
    path_pattern = ["/api/ethrpc"]
  }
}

resource "aws_lb_listener_rule" "api" {
  count        = var.instance_number > 0 ? var.instance_type == "api" ? 1 : 0 : 0
  listener_arn = var.alb_listener
  priority     = 4

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.common[0].arn
  }

  condition {
    path_pattern = ["/api"]
  }
}

resource "aws_lb_listener_rule" "graphiql" {
  count        = var.instance_number > 0 ? var.instance_type == "api" ? 1 : 0 : 0
  listener_arn = var.alb_listener
  priority     = 5

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.common[0].arn
  }

  condition {
    path_pattern = ["/graphiql"]
  }
}

resource "aws_lb_listener_rule" "web" {
  count        = var.instance_number > 0 ? var.instance_type == "web" ? 1 : 0 : 0
  listener_arn = var.alb_listener
  priority     = 6

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.common[0].arn
  }

  condition {
    path_pattern = ["/*"]
  }
}
