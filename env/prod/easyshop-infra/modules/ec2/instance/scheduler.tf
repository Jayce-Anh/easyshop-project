############################# EC2 Instance SCHEDULER #########################

resource "aws_scheduler_schedule" "stop" {
  name       = "Stop-${var.project.env}-${var.project.name}-ec2"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = "cron(0 18 * * ? *)"
  schedule_expression_timezone = "Asia/Singapore"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = aws_iam_role.scheduler.arn
    input = jsonencode({
      InstanceIds = [aws_instance.ec2.id]
    })
  }

  depends_on = [
    aws_instance.ec2,
    aws_iam_role_policy.scheduler,
  ]
}

resource "aws_scheduler_schedule" "start" {
  name       = "Start-${var.project.env}-${var.project.name}-ec2"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = "cron(0 9 * * ? *)"
  schedule_expression_timezone = "Asia/Singapore"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = aws_iam_role.scheduler.arn
    input = jsonencode({
      InstanceIds = [aws_instance.ec2.id]
    })
  }

  depends_on = [
    aws_instance.ec2,
    aws_iam_role_policy.scheduler,
  ]
}
