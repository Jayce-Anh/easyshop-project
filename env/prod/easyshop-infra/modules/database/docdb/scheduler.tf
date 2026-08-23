####################### DOCUMENTDB SCHEDULER #######################

resource "aws_scheduler_schedule" "stop" {
  name       = "Stop-${var.project.env}-${var.project.name}-docdb"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = "cron(0 18 * * ? *)"
  schedule_expression_timezone = "Asia/Singapore"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:stopDBCluster"
    role_arn = aws_iam_role.scheduler.arn
    input = jsonencode({
      DbClusterIdentifier = "${aws_docdb_cluster.db.cluster_identifier}"
    })
  }

  depends_on = [
    aws_docdb_cluster.db,
    aws_iam_role_policy.scheduler,
  ]
}

resource "aws_scheduler_schedule" "start" {
  name       = "Start-${var.project.env}-${var.project.name}-docdb"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = "cron(0 9 * * ? *)"
  schedule_expression_timezone = "Asia/Singapore"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:startDBCluster"
    role_arn = aws_iam_role.scheduler.arn
    input = jsonencode({
      DbClusterIdentifier = "${var.project.env}-${var.project.name}-docdb"
    })
  }

  depends_on = [
    aws_docdb_cluster.db,
    aws_iam_role_policy.scheduler,
  ]
}
