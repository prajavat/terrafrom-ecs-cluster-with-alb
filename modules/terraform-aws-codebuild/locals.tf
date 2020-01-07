locals {
    codebuild_backet_name = "${var.name}-${var.stage}-codebuild-bucket"
    codebuild_iam_policy_name_service = "${var.name}-${var.stage}-codebuild-iam-policy-service"
    codebuild_iam_role_name = "${var.name}-${var.stage}-codebuild-iam-role"
    codebuild_name = "${var.name}-${var.stage}-codebuild"
}