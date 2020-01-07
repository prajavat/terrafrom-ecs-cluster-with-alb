output "ecs_cluster_id" {
  value = aws_ecs_cluster.container_instance.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.container_instance.name
}

output "container_instance_security_group_id" {
  value = aws_security_group.container_instance.id
}

output "container_instance_ecs_for_ec2_service_role_name" {
  value = aws_iam_role.container_instance_ec2.name
}

output "ecs_service_role_name" {
  value = aws_iam_role.ecs_service_role.name
}

output "container_instance_autoscaling_group_name" {
  value = aws_autoscaling_group.container_instance.name
}

output "ecs_service_role_arn" {
  value = aws_iam_role.ecs_service_role.arn
}

output "container_instance_ecs_for_ec2_service_role_arn" {
  value = aws_iam_role.container_instance_ec2.arn
}

output "ecs_service_name" {
  value = aws_ecs_service.ecs_service.name
}

output "alb_dns_name" {
  value = aws_alb.loadbalancer.dns_name
}

output "autoscaling_group_az" {
  value = aws_autoscaling_group.container_instance.availability_zones
}