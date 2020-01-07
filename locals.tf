locals {
  codepipline_bucket_name = "${var.name}-${var.stage}-codepipeline-bucket"
  codepipline_name = "${var.name}-${var.stage}-codepipeline"
  codepipline_iam_role_name = "${var.name}-${var.stage}-codepipeline-iam-role"
  codepipline_iam_policy_name = "${var.name}-${var.stage}-codepipeline-iam-policy"
  codebuild_iam_policy_name = "${var.name}-${var.stage}-codebuild-iam-policy"
}

resource "random_string" "bucket_prefix" {
  length  = 12
  number  = false
  upper   = false
  special = false
  lower   = true
}

locals {
  cache_bucket_name = "${local.codepipline_bucket_name}${var.cache_bucket_suffix_enabled ? "-${join("", random_string.bucket_prefix.*.result)}" : ""}"

  cache_bucket_name_normalised = substr(
    join("-", split("_", lower(local.cache_bucket_name))),
    0,
    min(length(local.cache_bucket_name), 63),
  )
}