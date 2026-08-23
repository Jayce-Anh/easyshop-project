############################ CODE PIPELINE/BUILD/DEPLOY - OUTPUT ############################

#=================== Code Build ==================#
output "project_name" {
  value = {
    web-ui  = "${aws_codebuild_project.web_ui.name}"
    auth    = "${aws_codebuild_project.auth.name}"
    product = "${aws_codebuild_project.product.name}"
    cart    = "${aws_codebuild_project.cart.name}"
  }
}

output "project_arn" {
  value = {
    web-ui  = "${aws_codebuild_project.web_ui.arn}"
    auth    = "${aws_codebuild_project.auth.arn}"
    product = "${aws_codebuild_project.product.arn}"
    cart    = "${aws_codebuild_project.cart.arn}"
  }
}

#=================== Code Pipeline ==================#
output "codepipeline_name" {
  value = {
    web-ui  = "${aws_codepipeline.web_ui.name}"
    auth    = "${aws_codepipeline.auth.name}"
    product = "${aws_codepipeline.product.name}"
    cart    = "${aws_codepipeline.cart.name}"
    infra   = "${aws_codepipeline.infra.name}"
  }
}

output "codepipeline_arn" {
  value = {
    web-ui  = "${aws_codepipeline.web_ui.arn}"
    auth    = "${aws_codepipeline.auth.arn}"
    product = "${aws_codepipeline.product.arn}"
    cart    = "${aws_codepipeline.cart.arn}"
    infra   = "${aws_codepipeline.infra.arn}"
  }
}

output "bucket_artifact_name" {
  value = { for k, v in aws_s3_bucket.bucket_artifact : k => v.bucket }
}

output "github_connection_arn" {
  value = aws_codestarconnections_connection.github.arn
}

output "github_connection_status" {
  value = aws_codestarconnections_connection.github.connection_status
}

#=================== Code Deploy ==================#
# output "codedeploy_app_name" {
#   value = aws_codedeploy_app.codedeploy_app.name
# }

# output "codedeploy_deployment_group_name" {
#   value = aws_codedeploy_deployment_group.codedeploy_deployment_group.deployment_group_name
# }

# output "codedeploy_role_arn" {
#   value = aws_iam_role.codedeploy_role.arn
# }


