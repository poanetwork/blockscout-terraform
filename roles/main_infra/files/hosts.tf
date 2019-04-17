data "aws_ami" "explorer" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

resource "aws_launch_configuration" "explorer" {
  name_prefix                 = "${var.prefix}-explorer-launchconfig-"
  image_id                    = "${data.aws_ami.explorer.id}"
  instance_type               = "${var.instance_type}"
  security_groups             = ["${aws_security_group.app.id}"]
  key_name                    = "${var.key_name}"
  iam_instance_profile        = "${aws_iam_instance_profile.explorer.id}"
  associate_public_ip_address = false

  depends_on = ["aws_db_instance.default"]

  user_data = "${file("${path.module}/libexec/init.sh")}"

  root_block_device {
    volume_size = "${var.root_block_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_placement_group" "explorer" {
  count    = "${var.use_placement_group ? length(var.chains): 0}"
  name     = "${var.prefix}-explorer-placement-group${count.index}"
  strategy = "cluster"
}

resource "aws_autoscaling_group" "explorer" {
  count                = "${length(var.chains)}"
  name                 = "${aws_launch_configuration.explorer.name}-asg${count.index}"
  max_size             = "${length(var.chains) * 4}"
  min_size             = "${length(var.chains)}"
  desired_capacity     = "${length(var.chains)}"
  placement_group      = "${var.use_placement_group ? aws_placement_group.explorer.*.id[count.index] : "zero"}"
  launch_configuration = "${aws_launch_configuration.explorer.name}"
  vpc_zone_identifier  = ["${aws_subnet.default.id}"]
  availability_zones   = ["${data.aws_availability_zones.available.names}"]
  target_group_arns    = ["${aws_lb_target_group.explorer.*.arn[count.index]}"]

  # Health checks are performed by CodeDeploy hooks
  health_check_type = "EC2"

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances",
  ]

  depends_on = [
    "aws_ssm_parameter.db_host"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "prefix"
    value               = "${var.prefix}"
    propagate_at_launch = true
  }

  tag {
    key                 = "chain"
    value               = "${element(keys(var.chains),count.index)}"
    propagate_at_launch = true
  }
}

# TODO: These autoscaling policies are not currently wired up to any triggers
resource "aws_autoscaling_policy" "explorer-up" {
  count                  = "${length(var.chains)}"
  name                   = "${var.prefix}-explorer-autoscaling-policy-up${count.index}"
  autoscaling_group_name = "${element(aws_autoscaling_group.explorer.*.name, count.index)}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_autoscaling_policy" "explorer-down" {
  count                  = "${length(var.chains)}"
  name                   = "${var.prefix}-explorer-autoscaling-policy-down${count.index}"
  autoscaling_group_name = "${element(aws_autoscaling_group.explorer.*.name, count.index)}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}
