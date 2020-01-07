variable "region" {
  type        = string
  default     = "us-east-1"
}

variable "AWS_PROFILE" {
  default = "prajavat-terraform"
  description = "Setup aws access as profile"
}

# Application Variable
variable "name" {
  type        = string
  default     = "ironbridge"
  description = "This variable of your product/appilication name "
}

variable "stage" {
  type        = string
  default     = "prod"
  description = "This variable of your environment"
}

######## Codecommit/Repo Variable ########
variable "repo_name" {
  type        = string
  default     = "Irinbridge-laravel"
}

variable "branch" {
  type        = string
  default     = "master"
}

#### EC2 Instance Variable
variable "instance_type" {
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  type        = string
  default     = "app-prod"
}

variable "root_block_device_size" {
  default = "20"
}

######## ECS Cluster & LoadBalancer Variable ########

variable "container_port" {
  default = "80"
}

variable "abl_protocol" {
  default = "HTTP"
}

# variable "ssl_certificate_arn"{
#   default = ""
# }

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

variable "desired_capacity" {
  default = "1"
}

variable "deployment_minimum_healthy_percent" {
  default = "50"
}

variable "deployment_maximum_percent" {
  default = "200"
}

variable "health_check_path" {
  default = "/admin/login"
}

######## CodeBuild Variable ########
variable "build_image" {
  type        = string
  default     = "aws/codebuild/standard:1.0"
}

variable "build_compute_type" {
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "build_timeout" {
  type        = number
  default     = 60
}

variable "buildspec" {
  type        = string
  default     = "buildspec.yml"
}

variable "privileged_mode" {
  type        = bool
  default     = true
}

####### Required Variable ########
variable "environment_variables" {
  type = list(object(
    {
      name  = string
      value = string
  }))

  default     = []
}

variable "s3_bucket_force_destroy" {
  type        = bool
  default     = false
}

variable "enabled" {
  type        = bool
  default     = true
}

variable "badge_enabled" {
  type        = bool
  default     = false
}

variable "cache_bucket_suffix_enabled" {
  type        = bool
  default     = true
  description = "The cache bucket generates a random 13 character string to generate a unique bucket name. If set to false it uses terraform-null-label's id value"
}
