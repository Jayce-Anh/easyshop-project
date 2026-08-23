################################ IAM ################################

#======================== Scheduler IAM Role ==================#
resource "aws_iam_role" "scheduler" {
  name = "${var.project.env}-${var.project.name}-docdb-scheduler"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-docdb-scheduler"
    Module = "${path.module}"
  })
}

#======================== Scheduler IAM Policy ==================#
resource "aws_iam_role_policy" "scheduler" {
  name = "${var.project.env}-${var.project.name}-docdb-scheduler"
  role = aws_iam_role.scheduler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["rds:StartDBCluster", "rds:StopDBCluster"]
        Resource = "${aws_docdb_cluster.db.arn}"
      }
    ]
  })
}
