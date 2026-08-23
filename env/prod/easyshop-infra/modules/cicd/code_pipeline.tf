################################# CICD - CODE PIPELINE #################################

#================= CodePipeline - Web UI =================#
resource "aws_codepipeline" "web_ui" {
  name     = "${var.project.env}-${var.project.name}-web-ui"
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.bucket_artifact["web-ui"].bucket
    type     = "S3"
  }

  depends_on = [aws_s3_bucket_versioning.bucket_artifact]

  #Source Stage (GitHub v2 via CodeStar Connections)
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["Source_Artifacts"]

      configuration = {
        ConnectionArn        = aws_codestarconnections_connection.github.arn
        FullRepositoryId     = "${var.cicd_git.org}/${var.cicd_git.repos["web-ui"]}"
        BranchName           = "${var.cicd_git.branch}"
        OutputArtifactFormat = "CODE_ZIP"
        DetectChanges        = "true"
      }
    }
  }

  #Build Stage
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["Source_Artifacts"]
      output_artifacts = ["Build_Artifacts"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.web_ui.name
      }
    }
  }
}

#================= CodePipeline - Auth Service =================#
resource "aws_codepipeline" "auth" {
  name     = "${var.project.env}-${var.project.name}-auth"
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.bucket_artifact["auth"].bucket
    type     = "S3"
  }

  depends_on = [aws_s3_bucket_versioning.bucket_artifact]

  #Source Stage (GitHub v2 via CodeStar Connections)
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["Source_Artifacts"]

      configuration = {
        ConnectionArn        = aws_codestarconnections_connection.github.arn
        FullRepositoryId     = "${var.cicd_git.org}/${var.cicd_git.repos["auth"]}"
        BranchName           = "${var.cicd_git.branch}"
        OutputArtifactFormat = "CODE_ZIP"
        DetectChanges        = "true"
      }
    }
  }

  # Build Stage (CodeBuild)
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["Source_Artifacts"]
      output_artifacts = ["Build_Artifacts"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.auth.name
      }
    }
  }

  # Deploy Stage (ECS)
  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["Build_Artifacts"]
      version         = "1"

      configuration = {
        ClusterName = "${var.cicd_ecs_cluster}"
        ServiceName = "${var.project.env}-${var.project.name}-auth"
        FileName    = "artifact.json"
      }
    }
  }
}

#================= CodePipeline - Product Service =================#
resource "aws_codepipeline" "product" {
  name     = "${var.project.env}-${var.project.name}-product"
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.bucket_artifact["product"].bucket
    type     = "S3"
  }

  depends_on = [aws_s3_bucket_versioning.bucket_artifact]

  #Source Stage (GitHub v2 via CodeStar Connections)
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["Source_Artifacts"]

      configuration = {
        ConnectionArn        = aws_codestarconnections_connection.github.arn
        FullRepositoryId     = "${var.cicd_git.org}/${var.cicd_git.repos["product"]}"
        BranchName           = "${var.cicd_git.branch}"
        OutputArtifactFormat = "CODE_ZIP"
        DetectChanges        = "true"
      }
    }
  }

  # Build Stage (CodeBuild)
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["Source_Artifacts"]
      output_artifacts = ["Build_Artifacts"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.product.name
      }
    }
  }

  # Deploy Stage (ECS)
  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["Build_Artifacts"]
      version         = "1"

      configuration = {
        ClusterName = "${var.cicd_ecs_cluster}"
        ServiceName = "${var.project.env}-${var.project.name}-product"
        FileName    = "artifact.json"
      }
    }
  }
}

#================= CodePipeline - Cart Service =================#
resource "aws_codepipeline" "cart" {
  name     = "${var.project.env}-${var.project.name}-cart"
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.bucket_artifact["cart"].bucket
    type     = "S3"
  }

  depends_on = [aws_s3_bucket_versioning.bucket_artifact]

  #Source Stage (GitHub v2 via CodeStar Connections)
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["Source_Artifacts"]

      configuration = {
        ConnectionArn        = aws_codestarconnections_connection.github.arn
        FullRepositoryId     = "${var.cicd_git.org}/${var.cicd_git.repos["cart"]}"
        BranchName           = "${var.cicd_git.branch}"
        OutputArtifactFormat = "CODE_ZIP"
        DetectChanges        = "true"
      }
    }
  }

  # Build Stage (CodeBuild)
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["Source_Artifacts"]
      output_artifacts = ["Build_Artifacts"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.cart.name
      }
    }
  }

  # Deploy Stage (ECS)
  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["Build_Artifacts"]
      version         = "1"

      configuration = {
        ClusterName = "${var.cicd_ecs_cluster}"
        ServiceName = "${var.project.env}-${var.project.name}-cart"
        FileName    = "artifact.json"
      }
    }
  }
}

#================= CodePipeline - Infra =================#
resource "aws_codepipeline" "infra" {
  name     = "${var.project.env}-${var.project.name}-infra"
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.bucket_artifact["infra"].bucket
    type     = "S3"
  }

  depends_on = [aws_s3_bucket_versioning.bucket_artifact]

  #Source Stage (GitHub v2 via CodeStar Connections)
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["Source_Artifacts"]

      configuration = {
        ConnectionArn        = "${aws_codestarconnections_connection.github.arn}"
        FullRepositoryId     = "${var.cicd_git.org}/${var.cicd_git.repos["infra"]}"
        BranchName           = "${var.cicd_git.branch}"
        OutputArtifactFormat = "CODE_ZIP"
        DetectChanges        = "true"
      }
    }
  }

  # Plan Stage (fmt -check -> validate -> plan)
  stage {
    name = "Plan"

    action {
      name             = "Plan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["Source_Artifacts"]
      output_artifacts = ["Plan_Artifacts"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.infra.name
        EnvironmentVariables = jsonencode([
          { name = "TF_ACTION", value = "plan", type = "PLAINTEXT" }
        ])
      }
    }
  }

  # Manual approval before anything is applied to real infra
  stage {
    name = "Approval"

    action {
      name     = "ApprovePlan"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        CustomData = "Review the terraform plan output before approving apply."
      }
    }
  }

  # Apply Stage (applies the exact plan that was reviewed/approved)
  stage {
    name = "Apply"

    action {
      name            = "Apply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["Plan_Artifacts"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.infra.name
        EnvironmentVariables = jsonencode([
          { name = "TF_ACTION", value = "apply", type = "PLAINTEXT" }
        ])
      }
    }
  }
}

#================= GitHub v2 connection =================#
resource "aws_codestarconnections_connection" "github" {
  name          = "${var.project.env}-${var.project.name}-github"
  provider_type = "GitHub"

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-github"
    Module = "${path.module}"
  })
}
