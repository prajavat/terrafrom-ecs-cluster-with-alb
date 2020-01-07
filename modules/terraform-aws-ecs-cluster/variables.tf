variable "project" {}

variable "environment" {}

variable "region" {}

variable "desired_capacity" {}

variable "deployment_minimum_healthy_percent" {}

variable "deployment_maximum_percent" {}

variable "abl_protocol" {}

# variable "ssl_certificate_arn" {}

variable "health_check_path" {}

variable "container_port" {}

variable "lookup_latest_ami" {
  default = false
}

variable "ami_owners" {
  default = "amazon"
}

variable "ami_id" {
  default = "ami-6944c513"
}

variable "root_block_device_type" {
  default = "gp2"
}

variable "cpu_credit_specification" {
  default = "standard"
}

variable "instance_type" {}

variable "key_name" {}

variable "root_block_device_size" {}

variable "health_check_grace_period" {
  default = "600"
}

variable "min_size" {}

variable "max_size" {}

variable "min_capacity" {}

variable "max_capacity" {}

variable "service_launch_type" {
  default = "EC2"
}

variable "image_repo_name" {}

# variable "enabled_metrics" {
#   default = [
#     "GroupMinSize",
#     "GroupMaxSize",
#     "GroupDesiredCapacity",
#     "GroupInServiceInstances",
#     "GroupPendingInstances",
#     "GroupStandbyInstances",
#     "GroupTerminatingInstances",
#     "GroupTotalInstances",
#   ]
# }
