output "ECR_Image_Url" {
    value = module.terraform-aws-ecr.registry_url
}

output "LoadBalancer_DNS_Name" {
    value = module.terraform-aws-ecs-cluster.alb_dns_name
}