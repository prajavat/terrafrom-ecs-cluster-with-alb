variable "stage" {}

variable "name" {}

variable "badge_enabled" {}

variable "build_image" {}

variable "build_compute_type" {}

variable "build_timeout" {}

variable "buildspec" {}

variable "privileged_mode" {}

variable "enabled" {}

variable "image_repo_name" {}

variable "image_tag" {}

variable "environment_variables" {
  type = list(object(
    {
      name  = string
      value = string
  }))

  default = [
    {
      name  = "NO_ADDITIONAL_BUILD_VARS"
      value = "TRUE"
  }]

  description = "A list of maps, that contain both the key 'name' and the key 'value' to be used as additional environment variables for the build"
}

variable "cache_enabled" {
  type        = bool
  default     = true
  description = "If cache_enabled is true, create an S3 bucket for storing codebuild cache inside"
}

variable "cache_expiration_days" {
  default     = 7
  description = "How many days should the build cache be kept"
}

variable "cache_bucket_suffix_enabled" {
  type        = bool
  default     = true
  description = "The cache bucket generates a random 13 character string to generate a unique bucket name. If set to false it uses terraform-null-label's id value"
}

variable "github_token" {
  type        = string
  default     = ""
  description = "(Optional) GitHub auth token environment variable (`GITHUB_TOKEN`)"
}

variable "source_type" {
  type        = string
  default     = "CODEPIPELINE"
  description = "The type of repository that contains the source code to be built. Valid values for this parameter are: CODECOMMIT, CODEPIPELINE, GITHUB, GITHUB_ENTERPRISE, BITBUCKET or S3"
}

variable "source_location" {
  type        = string
  default     = ""
  description = "The location of the source code from git or s3"
}

variable "artifact_type" {
  type        = string
  default     = "CODEPIPELINE"
  description = "The build output artifact's type. Valid values for this parameter are: CODEPIPELINE, NO_ARTIFACTS or S3"
}

variable "report_build_status" {
  type        = bool
  default     = false
  description = "Set to true to report the status of a build's start and finish to your source provider. This option is only valid when the source_type is BITBUCKET or GITHUB"
}
