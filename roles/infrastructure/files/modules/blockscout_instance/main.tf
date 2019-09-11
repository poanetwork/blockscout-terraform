data "aws_ami" "explorer" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "init" {
  template = file("${path.module}/templates/init.sh.tpl")

  vars = {
    type = var.type 
  }
}

resource "aws_launch_configuration" "explorer" {
  count                       = var.instance_number > 0 ? 1 : 0
  name_prefix                 = "${var.prefix}-${var.chain}-${var.type}-launchconfig"
  image_id                    = data.aws_ami.explorer.id
  instance_type               = var.instance_type
  security_groups             = [var.security_app]
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_profile
  associate_public_ip_address = false
  

  user_data = data.template_file.init.rendered

  root_block_device {
    volume_size = var.root_block_size
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_placement_group" "explorer" {
  count    = var.use_placement_group == "True" ? 1 : 0 
  name     = "${var.prefix}-${var.chain}-${var.type}-explorer-pg"
  strategy = "cluster"
}

resource "aws_autoscaling_group" "explorer" {
  count                = var.instance_number > 0 ? 1 : 0
  name                 = "${var.prefix}-${var.chain}-${var.type}-asg"
  max_size             = var.instance_number + 1
  min_size             = "1"
  desired_capacity     = var.instance_number
  launch_configuration = aws_launch_configuration.explorer[0].name
  vpc_zone_identifier  = [var.aws_subnet] 
  target_group_arns    = [aws_lb_target_group.common[0].arn]
  placement_group      = var.use_placement_group == "True" ? "${var.prefix}-${var.chain}-${var.type}-explorer-pg" : null

  # Health checks are performed by CodeDeploy hooks
  health_check_type = "EC2"

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances",
  ]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "prefix"
    value               = var.prefix
    propagate_at_launch = true
  }

  tag {
    key                 = "chain"
    value               = var.chain
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${var.chain} ${var.type} application"
    propagate_at_launch = true
  }

  tag {
    key                 = "type"
    value               = var.type
    propagate_at_launch = true
  }
}

# TODO: These autoscaling policies are not currently wired up to any triggers
resource "aws_autoscaling_policy" "explorer-up" {
  count                  = var.instance_number > 0 ? 1 : 0
  name                   = "${var.prefix}-${var.chain}-{var.type}-explorer-asg-policy-up"
  autoscaling_group_name = aws_autoscaling_group.explorer[0].name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_autoscaling_policy" "explorer-down" {
  count                  = var.instance_number > 0 ? 1 : 0
  name                   = "${var.prefix}-${var.chain}-{var.type}-explorer-asg-policy-down"
  autoscaling_group_name = aws_autoscaling_group.explorer[0].name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

