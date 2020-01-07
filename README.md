# Terrafrom ECS Cluster with ALB & AutoScaling Gorup

This example uses only verified Terraform modules to create all resources that are needed for an ECS cluster that is sufficient for staging or production environment.

## Usage

To run this example you need to execute:

```bash
terraform init
terraform plan -out terraform.plan
terraform apply terraform.plan
```

Note that this example may create resources which can cost money (AWS EC2 instances, for example). Run `terraform destroy` when you don't need these resources.

## Inputs

| Name | Description | Type | Required |
|------|-------------|:----:|:-----:|
| name | This variable of your product/appilication name | string | yes |
| stage | This variable of your environment | string | yes |
| repo_name | Source repository of your application | string | yes |
| branch | Branch name of repository | string | yes |
| health_check_path | Health check path of application for terget group | string | yes |
| key_name | PEM file for access aws EC2 instance | string | yes |
| container_port | ECS Cluster, Container port | string | yes |
| abl_protocol | Application load-balancer protocol | string | yes |
| min_size | Minimum size of EC2 instamce in AutoScaling Group | string | no |
| max_size | Maximum size of EC2 instamce in AutoScaling Group | string | no |
| min_capacity | Minimum size of container of ECS service in ECS Cluster | string | no |
| max_capacity | Maximum size of container of ECS service in ECS Cluster | string | no |
| desired_capacity | Number of container must be run in ECS Cluster | string | no |
| deployment_minimum_healthy_percent | Deployment minimum health check percent | string | no |
| deployment_maximum_percent | Deployment maximum health check percent | string | no |
| root_block_device_size | EC2 instamce disk size | string | no |
| instance_type | EC2 instance type of AutoScaling Group | string | no |

## Outputs

| Name | Description |
|------|-------------|
| this\_ecs\_cluster\_arn |  |
| this\_ecs\_cluster\_id |  |
| this\_ecs\_cluster\_name | The name of the ECS cluster |

## Explanation

Current version creates an high-available VPC with instances that are attached to ECS. ECS tasks can be run on these instances but they are not exposed to anything.
