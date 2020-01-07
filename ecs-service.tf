resource "aws_security_group" "loadbalancer_sg" {
  vpc_id = module.main-vpc.vpc_id
  name  = local.loadbalancer_sg_name

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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
    Environment = var.environment
  }
}

#
# ALB resources
#
resource "aws_alb" "loadbalancer" {
  security_groups = [aws_security_group.loadbalancer_sg.id]
  subnets         = module.main-vpc.public_subnets
  name            = local.loadbalancer_name

  tags = {
    Name        = local.loadbalancer_name
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_alb_target_group" "loadbalancer" {
  name = local.target_group_name

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = var.abl_protocol
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }

  port     = var.container_port
  protocol = var.abl_protocol
  vpc_id = module.main-vpc.vpc_id

  tags = {
    Name        = local.target_group_name
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.loadbalancer.id
  port              = var.container_port
  protocol          = var.abl_protocol

  # certificate_arn = var.ssl_certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.loadbalancer.id
    type             = "forward"
  }
}

data "template_file" "task-definitions" {
  template = file("${path.module}/task-definitions/service.json")

  vars = {
    ecs_image_name = var.ecr_image_name
    image_tag = "latest"
    name = var.project
    port = var.container_port
    region = var.region
  }
}

resource "aws_ecs_task_definition" "ecs_task" {
  family = local.task_name
  container_definitions = data.template_file.task-definitions.rendered
  requires_compatibilities = [var.service_launch_type]
}

resource "aws_ecs_service" "ecs_service" {
  lifecycle {
    create_before_destroy = true
  }
  
  name = local.service_name
  cluster = aws_ecs_cluster.container_instance.id
  task_definition = aws_ecs_task_definition.ecs_task.arn

  desired_count = var.desired_capacity

  deployment_maximum_percent = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  load_balancer {
    target_group_arn = aws_alb_target_group.loadbalancer.id
    container_name   = var.project
    container_port   = var.container_port
  }
  depends_on = [
    aws_alb.loadbalancer,
    aws_alb_target_group.loadbalancer
  ]
}

#
# CloudWatch Matric resources
#
resource "aws_cloudwatch_metric_alarm" "cloudwatch_metric_high" {
  alarm_name          = local.alarm_name_hight
  alarm_actions       = [aws_appautoscaling_policy.up.arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "100000"

  dimensions = {
    LoadBalancer = aws_alb.loadbalancer.id
    TargetGroup  = aws_alb_target_group.loadbalancer.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudwatch_metric_low" {
  alarm_name          = local.alarm_name_low
  alarm_actions       = [aws_appautoscaling_policy.down.arn]
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"

  dimensions = {
    LoadBalancer = aws_alb.loadbalancer.id
    TargetGroup  = aws_alb_target_group.loadbalancer.arn_suffix
  }
}



#
# Application AutoScaling resources
#
resource "aws_appautoscaling_target" "main" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.container_instance.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity

  depends_on = [
    aws_ecs_service.ecs_service,
  ]
}

resource "aws_appautoscaling_policy" "up" {
  name               = local.autoscaling_policy_up
  resource_id        = "service/${aws_ecs_cluster.container_instance.name}/${aws_ecs_service.ecs_service.name}"
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
  policy_type        = "StepScaling"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = "300"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 5
      scaling_adjustment          = 1
    }
  }

  depends_on = [
    aws_appautoscaling_target.main,
  ]
}

resource "aws_appautoscaling_policy" "down" {
  name               = local.autoscaling_policy_down
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.container_instance.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = "300"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [
    aws_appautoscaling_target.main,
  ]
}
