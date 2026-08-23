################################### CODE PIPELINE/BUILD/DEPLOY - IAM ############################################

#================= CodePipeline =================#
# Role
resource "aws_iam_role" "pipeline_role" {
  name = "${var.project.env}-${var.project.name}-codepipeline"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Policy
resource "aws_iam_role_policy" "codepipeline_policy" {
  role = aws_iam_role.pipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:PassRole"
        ],
        Resource = "*",
        Effect   = "Allow",
        Condition = {
          StringEqualsIfExists = {
            "iam:PassedToService" = [
              "cloudformation.amazonaws.com",
              "elasticbeanstalk.amazonaws.com",
              "ec2.amazonaws.com",
              "ecs-tasks.amazonaws.com"
            ]
          }
        }
      },
      {
        Action = [
          "codecommit:CancelUploadArchive",
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:GetRepository",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:UploadArchive"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action = [
          "codestar-connections:UseConnection",
          "codeconnections:UseConnection"
        ],
        Resource = [
          "${aws_codestarconnections_connection.github.arn}",
          replace("${aws_codestarconnections_connection.github.arn}", "codestar-connections", "codeconnections")
        ],
        Effect = "Allow"
      },
      {
        Action = [
          "elasticbeanstalk:*",
          "ec2:*",
          "elasticloadbalancing:*",
          "autoscaling:*",
          "cloudwatch:*",
          "s3:*",
          "sns:*",
          "cloudformation:*",
          "rds:*",
          "sqs:*",
          "ecs:*"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action = [
          "lambda:InvokeFunction",
          "lambda:ListFunctions"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action = [
          "opsworks:CreateDeployment",
          "opsworks:DescribeApps",
          "opsworks:DescribeCommands",
          "opsworks:DescribeDeployments",
          "opsworks:DescribeInstances",
          "opsworks:DescribeStacks",
          "opsworks:UpdateApp",
          "opsworks:UpdateStack"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action = [
          "cloudformation:CreateStack",
          "cloudformation:DeleteStack",
          "cloudformation:DescribeStacks",
          "cloudformation:UpdateStack",
          "cloudformation:CreateChangeSet",
          "cloudformation:DeleteChangeSet",
          "cloudformation:DescribeChangeSet",
          "cloudformation:ExecuteChangeSet",
          "cloudformation:SetStackPolicy",
          "cloudformation:ValidateTemplate"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuildBatches",
          "codebuild:StartBuildBatch"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Effect = "Allow",
        Action = [
          "devicefarm:ListProjects",
          "devicefarm:ListDevicePools",
          "devicefarm:GetRun",
          "devicefarm:GetUpload",
          "devicefarm:CreateUpload",
          "devicefarm:ScheduleRun"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "servicecatalog:ListProvisioningArtifacts",
          "servicecatalog:CreateProvisioningArtifact",
          "servicecatalog:DescribeProvisioningArtifact",
          "servicecatalog:DeleteProvisioningArtifact",
          "servicecatalog:UpdateProduct"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "cloudformation:ValidateTemplate"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:DescribeImages"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "states:DescribeExecution",
          "states:DescribeStateMachine",
          "states:StartExecution"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "appconfig:StartDeployment",
          "appconfig:StopDeployment",
          "appconfig:GetDeployment"
        ],
        Resource = "*"
      }
    ]
  })
}

#================= CodeBuild =================#
# Role
resource "aws_iam_role" "codebuild_role" {
  name = "${var.project.env}-${var.project.name}-codebuild"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })

}

# Policy
resource "aws_iam_role_policy" "s3_policy_cicd" {
  role = aws_iam_role.codebuild_role.name

  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Resource = [
            "*"
          ],
          Action = [
            "logs:*"
          ]
        },
        {
          Effect = "Allow",
          Resource = [
            "*"
          ],
          Action = [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:CompleteLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:InitiateLayerUpload",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetAuthorizationToken",
            "ecr:PutImage"
          ]
        },
        {
          Effect = "Allow",
          Resource = [
            "*"
          ],
          Action = [
            "ssm:DescribeParameters",
            "ssm:GetParameter"
          ]
        },
        {
          Effect = "Allow",
          Action = [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:PutObject",
            "s3:PutObjectTagging",
            "s3:DeleteObject",
            "s3:ListBucket",
            "s3:GetBucketVersioning"
          ],
          Resource = concat(
            flatten([
              for b in aws_s3_bucket.bucket_artifact : [b.arn, "${b.arn}/*"]
            ]),
            [
              "arn:aws:s3:::${var.cicd_ui_env.s3_bucket_name}",
              "arn:aws:s3:::${var.cicd_ui_env.s3_bucket_name}/*"
            ]
          )
        },
        {
          Effect = "Allow",
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ],
          Resource = ["*"]
        },
        {
          Effect = "Allow",
          Action = [
            "kms:Decrypt",
            "kms:DescribeKey",
            "kms:GenerateDataKey"
          ],
          Resource = ["*"]
        },
        {
          Action = [
            "cloudfront:CreateInvalidation",
            "cloudfront:GetDistribution",
            "cloudfront:GetStreamingDistribution",
            "cloudfront:GetDistributionConfig",
            "cloudfront:GetInvalidation",
            "cloudfront:ListInvalidations",
            "cloudfront:ListStreamingDistributions",
            "cloudfront:ListDistributions"
          ],
          Effect   = "Allow",
          Resource = ["*"]
        }
      ]
    }
  )
}

#================= CodeDeploy =================#
# # Role
# resource "aws_iam_role" "codedeploy_role" {
#   name               = "${var.project.env}-${var.project.name}-codedeploy"
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "",
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "codedeploy.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }

# # Policy
# resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
#   role       = aws_iam_role.codedeploy_role.name
# }

# resource "aws_iam_role_policy_attachment" "AWSCodeDeployRoleForECS" {
#   policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
#   role       = aws_iam_role.codedeploy_role.name
# }

#================= CodeBuild - Infra (terraform fmt/validate/plan/apply) =================#
# Dedicated role, kept separate from aws_iam_role.codebuild_role above, because
# Terraform needs much broader permissions (it manages IAM roles/policies,
# VPC, ECS, RDS, KMS, etc.) than the app build/deploy projects need.

# Permissions boundary - caps this role so PowerUser + IAMFullAccess below
# can never be used to create/attach an unrestricted admin identity.
resource "aws_iam_policy" "terraform_boundary" {
  name        = "${var.project.env}-${var.project.name}-infra-terraform-boundary"
  description = "Permissions boundary for the Terraform CodeBuild role - blocks privilege escalation"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "BaselineAllow"
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      },
      {
        Sid    = "DenyIAMUserAndCredentialCreation"
        Effect = "Deny"
        Action = [
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:CreateAccessKey",
          "iam:UpdateAccessKey",
          "iam:CreateLoginProfile",
          "iam:UpdateLoginProfile",
          "iam:CreateVirtualMFADevice",
          "iam:DeactivateMFADevice",
          "iam:DeleteVirtualMFADevice",
          "iam:UploadSSHPublicKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyAttachingAdminPolicies"
        Effect = "Deny"
        Action = [
          "iam:AttachUserPolicy",
          "iam:AttachRolePolicy",
          "iam:AttachGroupPolicy"
        ]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "iam:PolicyARN" = [
              "arn:aws:iam::aws:policy/AdministratorAccess",
              "arn:aws:iam::aws:policy/IAMFullAccess"
            ]
          }
        }
      },
      {
        # Forces every new role this pipeline creates to also carry this
        # same boundary, so it can't create an "escape hatch" role.
        Sid    = "DenyRoleCreationWithoutBoundary"
        Effect = "Deny"
        Action = [
          "iam:CreateRole",
          "iam:PutRolePermissionsBoundary"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "iam:PermissionsBoundary" = "arn:aws:iam::${var.project.account_id}:policy/${var.project.env}-${var.project.name}-infra-terraform-boundary"
          }
        }
      },
      {
        # Prevents removing the boundary from itself or any role.
        Sid    = "DenyBoundaryRemoval"
        Effect = "Deny"
        Action = [
          "iam:DeleteRolePermissionsBoundary"
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyOrgAndAccountRootActions"
        Effect = "Deny"
        Action = [
          "organizations:*",
          "account:*",
          "aws-portal:*",
          "iam:DeleteAccountPasswordPolicy",
          "iam:UpdateAccountPasswordPolicy"
        ]
        Resource = "*"
      }
    ]
  })
}

# Role
resource "aws_iam_role" "codebuild_infra_role" {
  name                 = "${var.project.env}-${var.project.name}-infra-codebuild"
  permissions_boundary = aws_iam_policy.terraform_boundary.arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "codebuild.amazonaws.com" }
      }
    ]
  })

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-infra-codebuild"
    Module = "${path.module}"
  })
}

# Bootstrap-phase permissions. Tighten to a scoped custom policy once real
# usage is known (see docs/README.md CI/CD section).
resource "aws_iam_role_policy_attachment" "codebuild_infra_poweruser" {
  role       = aws_iam_role.codebuild_infra_role.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_role_policy_attachment" "codebuild_infra_iam_full" {
  role       = aws_iam_role.codebuild_infra_role.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}