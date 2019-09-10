locals {
  route_patterns = {
    "regular" = [],
    "api" = [
      {
        "priority" = "5"
        "block" = {
          "path_pattern" = ["/api"]
        }
      },
      {
        "priority" = "3"
        "block" = {
          "path_pattern" = ["/api/ethrpc"]
        }
      },
      {
        "priority" = "4"
        "block" = {
          "path_pattern" = ["/graphiql"]
        }
      }
    ],
    "web" = [
      {
        "priority" = "6"
        "block" = { 
          "path_pattern" = ["/"]
        }
      },
      {
        "priority" = "1",
        "block" = {
          "query_string" = {
            "key"        = "action",
            "value"      = "verify",
          }
        }
      },
      {
        "priority" = "2",
        "block" = {
          "query_string" = {
            "key"        = "action",
            "value"      = "eth_block_number",
          }
        }
      }
    ]
  }
}

# The Target Group for the ALB
resource "aws_lb_target_group" "common" {
  count    = var.instance_number > 0 ? 1 : 0
  name     = "${var.prefix}-explorer-${var.type}-${var.chain}-alb-target"
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

resource "aws_lb_listener_rule" "host_based_routing" {
  count        = length(local.route_patterns[var.type])
  listener_arn = var.alb_listener
  priority     = local.route_patterns[var.type][count.index].priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.common.arn
  }

  condition = local.route_patterns[var.type][count.index].block
}
