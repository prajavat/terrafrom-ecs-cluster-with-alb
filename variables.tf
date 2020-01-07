variable "project" {}

variable "environment" {}

variable "key_name" {}

variable "ecr_image_name" {}

variable "region" {
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
}

variable "abl_protocol" {
  default = "HTTP"
}

variable "container_port" {
  default = "80"
}

variable "desired_capacity" {
  default = "1"
}

variable "min_size" {
  default = "1"
}

variable "max_size" {
  default = "2"
}

variable "min_capacity" {
  default = "1"
}

variable "max_capacity" {
  default = "10"
}

variable "deployment_minimum_healthy_percent" {
  default = "50"
}

variable "deployment_maximum_percent" {
  default = "200"
}

variable "health_check_path" {
  default = "/"
}

variable "root_block_device_size" {
  default = "20"
}

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

variable "health_check_grace_period" {
  default = "600"
}

variable "service_launch_type" {
  default = "EC2"
}

# variable "ssl_certificate_arn" {
#   default = "ARN"
# }