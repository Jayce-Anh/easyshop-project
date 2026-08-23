########################### EC2 IAM ##########################

#================= EC2 Instance ==================#
# Roles 
resource "aws_iam_role" "ec2" {
  name = "${var.project.env}-${var.project.name}-ec2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = ["sts:AssumeRole"]
        Principal = { Service = ["ec2.amazonaws.com"] }
      }
    ]
  })
}

# Policies
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy" "s3_web_ui" {
  name = "${var.project.env}-${var.project.name}-ec2-s3-web-ui"
  role = aws_iam_role.ec2.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3WebUi"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.project.env}-${var.project.name}-cloudfront",
          "arn:aws:s3:::${var.project.env}-${var.project.name}-cloudfront/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "assume_ci_provider" {
  name = "${var.project.env}-${var.project.name}-ec2-assume-ci-provider"
  role = aws_iam_role.ec2.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sts:AssumeRole"]
        Resource = "${aws_iam_role.ci_provider.arn}"
      }
    ]
  })
}

#================= EC2 Instance Profile ==================#
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project.env}-${var.project.name}-ec2"
  role = aws_iam_role.ec2.name
}

#================= GitHub CI Provider ==================#
# Roles
resource "aws_iam_role" "ci_provider" {
  name = "${var.project.env}-${var.project.name}-github-ci-provider"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "${aws_iam_openid_connect_provider.github.arn}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = ["sts.amazonaws.com"]
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              for repo in values(var.cicd_git.repos) :
              "repo:${var.cicd_git.org}/${repo}:*"
            ]
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = "${aws_iam_role.ec2.arn}"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-github-ci-provider"
    Module = "${path.module}"
  })
}

# Policies
resource "aws_iam_role_policy_attachment" "ci_provider_poweruser" {
  role       = aws_iam_role.ci_provider.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_role_policy_attachment" "ci_provider_iam" {
  role       = aws_iam_role.ci_provider.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

#================= Scheduler IAM ==================#
# Roles 
resource "aws_iam_role" "scheduler" {
  name = "${var.project.env}-${var.project.name}-ec2-scheduler"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = { Service = "scheduler.amazonaws.com" }
      }
    ]
  })

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-ec2-scheduler"
    Module = "${path.module}"
  })
}

# Attach Policies
resource "aws_iam_role_policy" "scheduler" {
  name = "${var.project.env}-${var.project.name}-ec2-scheduler"
  role = aws_iam_role.scheduler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:StartInstances", "ec2:StopInstances"]
        Resource = "${aws_instance.ec2.arn}"
      }
    ]
  })
}
