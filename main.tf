provider "aws" {
  region = var.region
}

#
# Container Instance IAM resources
#
data "aws_iam_policy_document" "container_instance_ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "container_instance_ec2" {
  name               = local.ecs_for_ec2_service_role_name
  assume_role_policy = data.aws_iam_policy_document.container_instance_ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerServiceforEC2Role" {
  role       = aws_iam_role.container_instance_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2FullAccess" {
  role       = aws_iam_role.container_instance_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_instance_profile" "container_instance" {
  name = aws_iam_role.container_instance_ec2.name
  role = aws_iam_role.container_instance_ec2.name
}

#
# ECS Service IAM permissions
#

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_service_role" {
  name               = local.ecs_service_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_service_role" {
  role       = aws_iam_role.ecs_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecs_autoscale_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["application-autoscaling.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

#
# Security group resources
#
resource "aws_security_group" "container_instance" {
  vpc_id = module.main-vpc.vpc_id
  name  = local.security_group_name

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project     = var.project
    Environment = var.stage
  }
}

#
# ECS Autoscaling Group resources
#
data "template_file" "container_instance_base_cloud_config" {
  template = file("${path.module}/cloud-config/base-container-instance.yml.tpl")

  vars = {
    ecs_cluster_name = aws_ecs_cluster.container_instance.name
  }
}

data "template_cloudinit_config" "container_instance_cloud_config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.container_instance_base_cloud_config.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content  = file("${path.module}/cloud-config/docker-plugin.sh")
  }

}

data "aws_ami" "ecs_ami" {
  count       = var.lookup_latest_ami ? 1 : 0
  most_recent = true
  owners      = [var.ami_owners]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "user_ami" {
  count  = var.lookup_latest_ami ? 0 : 1
  owners = [var.ami_owners]

  filter {
    name   = "image-id"
    values = [var.ami_id]
  }
}

resource "aws_launch_template" "container_instance" {
  name  = "${var.project}-${var.stage}-template"
  block_device_mappings {
    device_name = var.lookup_latest_ami ? join("", data.aws_ami.ecs_ami.*.root_device_name) : join("", data.aws_ami.user_ami.*.root_device_name)

    ebs {
      volume_type = var.root_block_device_type
      volume_size = var.root_block_device_size
    }
  }

  credit_specification {
    cpu_credits = var.cpu_credit_specification
  }

  disable_api_termination = false

  
  iam_instance_profile {
    name = aws_iam_instance_profile.container_instance.name
  }

  image_id = var.lookup_latest_ami ? join("", data.aws_ami.ecs_ami.*.image_id) : join("", data.aws_ami.user_ami.*.image_id)

  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = var.instance_type
  key_name                             = var.key_name
  vpc_security_group_ids               = [aws_security_group.container_instance.id]
  user_data                            = base64encode(data.template_cloudinit_config.container_instance_cloud_config.rendered)

  monitoring {
    enabled = true
  }
}

resource "aws_autoscaling_policy" "policy" {
  name                      = "${var.project}-${var.stage}-policy"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.container_instance.name
  estimated_instance_warmup = 200

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = "60"
  }
}

resource "aws_autoscaling_group" "container_instance" {
  lifecycle {
    create_before_destroy = true
  }

  name = local.autoscaling_group_name

  launch_template {
    id = aws_launch_template.container_instance.id
    version = "$Latest"
  }

  health_check_grace_period = var.health_check_grace_period
  health_check_type         = "EC2"
  desired_capacity          = var.desired_capacity
  termination_policies      = ["OldestLaunchConfiguration", "Default"]
  min_size                  = var.min_size
  max_size                  = var.max_size

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]



  vpc_zone_identifier       = module.main-vpc.public_subnets

  tag {
    key                 = "Name"
    value               = local.instance_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.stage
    propagate_at_launch = true
  }
}


#
# ECS Cluster resources
#
resource "aws_ecs_cluster" "container_instance" {
  name = local.cluster_name
}
