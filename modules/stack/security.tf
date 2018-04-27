data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "deployer-assume-role-policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "config-policy" {
  statement {
    effect  = "Allow"
    actions = ["ssm:DescribeParameters"]

    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]

    resources = [
      "arn:aws:ssm:*:*:parameter/${var.prefix}/*",
      "arn:aws:ssm:*:*:parameter/${var.prefix}/*/*",
    ]
  }

  statement {
    effect  = "Allow"
    actions = ["ec2:DescribeTags"]

    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = ["s3:*"]

    resources = [
      "arn:aws:s3:::aws-codedeploy-us-east-1/*",
      "arn:aws:s3:::aws-codedeploy-us-east-2/*",
      "arn:aws:s3:::aws-codedeploy-us-west-1/*",
      "arn:aws:s3:::aws-codedeploy-us-west-2/*",
      "arn:aws:s3:::aws-codedeploy-ap-northeast-1/*",
      "arn:aws:s3:::aws-codedeploy-ap-northeast-2/*",
      "arn:aws:s3:::aws-codedeploy-ap-south-1/*",
      "arn:aws:s3:::aws-codedeploy-ap-southeast-1/*",
      "arn:aws:s3:::aws-codedeploy-ap-southeast-2/*",
      "arn:aws:s3:::aws-codedeploy-eu-central-1/*",
      "arn:aws:s3:::aws-codedeploy-eu-west-1/*",
      "arn:aws:s3:::aws-codedeploy-sa-east-1/*",
    ]
  }
}

data "aws_iam_policy_document" "codedeploy-policy" {
  statement {
    effect = "Allow"

    actions = [
      "autoscaling:CompleteLifecycleAction",
      "autoscaling:DeleteLifecycleHook",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeLifecycleHooks",
      "autoscaling:PutLifecycleHook",
      "autoscaling:RecordLifecycleActionHeartbeat",
      "codedeploy:*",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "tag:GetTags",
      "tag:GetResources",
      "sns:Publish",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = ["s3:Get*", "s3:List*"]

    resources = [
      "${aws_s3_bucket.explorer_releases.arn}",
      "${aws_s3_bucket.explorer_releases.arn}/*",
      "arn:aws:s3:::aws-codedeploy-us-east-1/*",
      "arn:aws:s3:::aws-codedeploy-us-east-2/*",
      "arn:aws:s3:::aws-codedeploy-us-west-1/*",
      "arn:aws:s3:::aws-codedeploy-us-west-2/*",
      "arn:aws:s3:::aws-codedeploy-ap-northeast-1/*",
      "arn:aws:s3:::aws-codedeploy-ap-northeast-2/*",
      "arn:aws:s3:::aws-codedeploy-ap-south-1/*",
      "arn:aws:s3:::aws-codedeploy-ap-southeast-1/*",
      "arn:aws:s3:::aws-codedeploy-ap-southeast-2/*",
      "arn:aws:s3:::aws-codedeploy-eu-central-1/*",
      "arn:aws:s3:::aws-codedeploy-eu-west-1/*",
      "arn:aws:s3:::aws-codedeploy-sa-east-1/*",
    ]
  }
}

resource "aws_iam_instance_profile" "explorer" {
  name = "${var.prefix}-explorer-profile"
  role = "${aws_iam_role.role.name}"
  path = "/${var.prefix}/"
}

resource "aws_iam_role_policy" "config" {
  name   = "${var.prefix}-config-policy"
  role   = "${aws_iam_role.role.id}"
  policy = "${data.aws_iam_policy_document.config-policy.json}"
}

resource "aws_iam_role" "role" {
  name               = "${var.prefix}-explorer-role"
  description        = "The IAM role given to each Explorer instance"
  path               = "/${var.prefix}/"
  assume_role_policy = "${data.aws_iam_policy_document.instance-assume-role-policy.json}"
}

resource "aws_iam_role_policy" "deployer" {
  name   = "${var.prefix}-codedeploy-policy"
  role   = "${aws_iam_role.deployer.id}"
  policy = "${data.aws_iam_policy_document.codedeploy-policy.json}"
}

resource "aws_iam_role" "deployer" {
  name               = "${var.prefix}-deployer-role"
  description        = "The IAM role given to the CodeDeploy service"
  assume_role_policy = "${data.aws_iam_policy_document.deployer-assume-role-policy.json}"
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  name        = "${var.prefix}-poa-elb"
  description = "A security group for the app server ELB, so it is accessible via the web"
  vpc_id      = "${aws_vpc.vpc.id}"

  # HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Unrestricted outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    prefix = "${var.prefix}"
    origin = "terraform"
  }
}

resource "aws_security_group" "app" {
  name        = "${var.prefix}-poa-app"
  description = "A security group for the app server, allowing SSH and HTTP(S)"
  vpc_id      = "${aws_vpc.vpc.id}"

  # HTTP from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  # HTTPS from the VPC
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  # SSH from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Unrestricted outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    prefix = "${var.prefix}"
    origin = "terraform"
  }
}

resource "aws_security_group" "database" {
  name        = "${var.prefix}-poa-database"
  description = "Allow any inbound traffic from public/private subnet"
  vpc_id      = "${aws_vpc.vpc.id}"

  # Allow anything from within the app server subnet
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  # Unrestricted outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    prefix = "${var.prefix}"
    origin = "terraform"
  }
}

resource "aws_security_group" "redis" {
  name        = "${var.prefix}-poa-redis"
  description = "Allow any inbound traffic from public/private subnet"
  vpc_id      = "${aws_vpc.vpc.id}"

  # Allow traffic from within app server subnet
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  # Unrestricted outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    prefix = "${var.prefix}"
    origin = "terraform"
  }
}
