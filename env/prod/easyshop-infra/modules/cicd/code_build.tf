################################# CICD - CODE BUILD #################################

#================== Web UI ===================#
resource "aws_codebuild_project" "web_ui" {
  name         = "${var.project.env}-${var.project.name}-web-ui"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    type            = "LINUX_CONTAINER"
    image           = "aws/codebuild/standard:6.0"
    privileged_mode = true

    dynamic "environment_variable" {
      for_each = local.env_vars.web-ui
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline/prod-easyshop-frontend.yml")
  }

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-web-ui"
    Module = "${path.module}"
  })
}

#================== Auth Service ===================#
resource "aws_codebuild_project" "auth" {
  name         = "${var.project.env}-${var.project.name}-auth"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    type            = "LINUX_CONTAINER"
    image           = "aws/codebuild/standard:6.0"
    privileged_mode = true

    dynamic "environment_variable" {
      for_each = local.env_vars.auth
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline/prod-easyshop-backend.yml")
  }

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-auth"
    Module = "${path.module}"
  })
}

#================== Product Service ===================#
resource "aws_codebuild_project" "product" {
  name         = "${var.project.env}-${var.project.name}-product"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    type            = "LINUX_CONTAINER"
    image           = "aws/codebuild/standard:6.0"
    privileged_mode = true

    dynamic "environment_variable" {
      for_each = local.env_vars.product
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline/prod-easyshop-backend.yml")
  }

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-product"
    Module = "${path.module}"
  })
}

#================== Cart Service ===================#
resource "aws_codebuild_project" "cart" {
  name         = "${var.project.env}-${var.project.name}-cart"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    type            = "LINUX_CONTAINER"
    image           = "aws/codebuild/standard:6.0"
    privileged_mode = true

    dynamic "environment_variable" {
      for_each = local.env_vars.cart
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline/prod-easyshop-backend.yml")
  }

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-cart"
    Module = "${path.module}"
  })
}

#================== Infra ===================#
resource "aws_codebuild_project" "infra" {
  name         = "${var.project.env}-${var.project.name}-infra"
  service_role = aws_iam_role.codebuild_infra_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    type            = "LINUX_CONTAINER"
    image           = "aws/codebuild/standard:7.0"
    privileged_mode = false

    environment_variable {
      name  = "TF_VERSION"
      value = "1.10.0"
    }

    # Default/fallback action if a pipeline action doesn't override it.
    environment_variable {
      name  = "TF_ACTION"
      value = "plan"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline/prod-easyshop-infra.yml")
  }

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-infra"
    Module = "${path.module}"
  })
}
