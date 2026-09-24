############################# ECS CLOUDWATCH #####################################

#================== CloudWatch Log Group ==================#
resource "aws_cloudwatch_log_group" "auth" {
  name              = "/ecs/${var.project.env}-${var.project.name}-auth"
  retention_in_days = 7

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-auth"
    Module = "${path.module}"
  })
}

resource "aws_cloudwatch_log_group" "product" {
  name              = "/ecs/${var.project.env}-${var.project.name}-product"
  retention_in_days = 7

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-product"
    Module = "${path.module}"
  })
}

resource "aws_cloudwatch_log_group" "cart" {
  name              = "/ecs/${var.project.env}-${var.project.name}-cart"
  retention_in_days = 7

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-cart"
    Module = "${path.module}"
  })
}

#================== SNS topic for ECS alarm notifications ==================#
resource "aws_sns_topic" "ecs_alarms" {
  name = "${var.project.env}-${var.project.name}-ecs-alarms"

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-ecs-alarms"
    Module = "${path.module}"
  })
}

resource "aws_sns_topic_subscription" "ecs_alarms_email" {
  count     = length(var.alarm_emails) > 0 ? length(var.alarm_emails) : 0
  topic_arn = aws_sns_topic.ecs_alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_emails[count.index]
}

#================== ECS CPU/Memory alarms (> threshold) ==================#
locals {
  ecs_service_names = {
    auth    = aws_ecs_service.auth.name
    product = aws_ecs_service.product.name
    cart    = aws_ecs_service.cart.name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  for_each = local.ecs_service_names

  alarm_name          = "${var.project.env}-${var.project.name}-${each.key}-cpu-high"
  alarm_description   = "ECS ${each.key} service CPUUtilization above ${var.ecs_cpu_alarm_threshold}%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = var.ecs_cpu_alarm_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = each.value
  }

  alarm_actions = [aws_sns_topic.ecs_alarms.arn]
  ok_actions    = [aws_sns_topic.ecs_alarms.arn]

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-${each.key}-cpu-high"
    Module = "${path.module}"
  })
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  for_each = local.ecs_service_names

  alarm_name          = "${var.project.env}-${var.project.name}-${each.key}-memory-high"
  alarm_description   = "ECS ${each.key} service MemoryUtilization above ${var.ecs_memory_alarm_threshold}%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = var.ecs_memory_alarm_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = each.value
  }

  alarm_actions = [aws_sns_topic.ecs_alarms.arn]
  ok_actions    = [aws_sns_topic.ecs_alarms.arn]

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-${each.key}-memory-high"
    Module = "${path.module}"
  })
}

#================== CloudWatch Dashboard (ECS CPU/RAM) ==================#
resource "aws_cloudwatch_dashboard" "ecs" {
  dashboard_name = "${var.project.env}-${var.project.name}-ecs-observability"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "ECS CPU Utilization (%)"
          region  = var.project.region
          view    = "timeSeries"
          stacked = false
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.ecs_cluster.name, "ServiceName", aws_ecs_service.auth.name, { label = "auth" }],
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.ecs_cluster.name, "ServiceName", aws_ecs_service.product.name, { label = "product" }],
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.ecs_cluster.name, "ServiceName", aws_ecs_service.cart.name, { label = "cart" }],
          ]
          annotations = {
            horizontal = [{ label = "Alarm threshold", value = var.ecs_cpu_alarm_threshold }]
          }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "ECS Memory Utilization (%)"
          region  = var.project.region
          view    = "timeSeries"
          stacked = false
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.ecs_cluster.name, "ServiceName", aws_ecs_service.auth.name, { label = "auth" }],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.ecs_cluster.name, "ServiceName", aws_ecs_service.product.name, { label = "product" }],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.ecs_cluster.name, "ServiceName", aws_ecs_service.cart.name, { label = "cart" }],
          ]
          annotations = {
            horizontal = [{ label = "Alarm threshold", value = var.ecs_memory_alarm_threshold }]
          }
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          title  = "Recent Application Logs (auth / product / cart)"
          region = var.project.region
          view   = "table"
          query  = "SOURCE '${aws_cloudwatch_log_group.auth.name}' | SOURCE '${aws_cloudwatch_log_group.product.name}' | SOURCE '${aws_cloudwatch_log_group.cart.name}' | fields @timestamp, @log, @message | sort @timestamp desc | limit 50"
        }
      },
    ]
  })
}