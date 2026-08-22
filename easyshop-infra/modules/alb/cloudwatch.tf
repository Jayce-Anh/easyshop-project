############################# ALB CLOUDWATCH #####################################

#================== CloudWatch Dashboard (ALB error rate) ==================#
resource "aws_cloudwatch_dashboard" "alb" {
  dashboard_name = "${var.project.env}-${var.project.name}-alb-observability"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ALB Target 4XX/5XX Errors"
          region = var.project.region
          view   = "timeSeries"
          stat   = "Sum"
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", aws_lb.lb.arn_suffix, "TargetGroup", aws_lb_target_group.auth.arn_suffix, { label = "auth-5xx" }],
            ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", aws_lb.lb.arn_suffix, "TargetGroup", aws_lb_target_group.auth.arn_suffix, { label = "auth-4xx" }],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", aws_lb.lb.arn_suffix, "TargetGroup", aws_lb_target_group.product.arn_suffix, { label = "product-5xx" }],
            ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", aws_lb.lb.arn_suffix, "TargetGroup", aws_lb_target_group.product.arn_suffix, { label = "product-4xx" }],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", aws_lb.lb.arn_suffix, "TargetGroup", aws_lb_target_group.cart.arn_suffix, { label = "cart-5xx" }],
            ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", aws_lb.lb.arn_suffix, "TargetGroup", aws_lb_target_group.cart.arn_suffix, { label = "cart-4xx" }],
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ALB Request Count"
          region = var.project.region
          view   = "timeSeries"
          stat   = "Sum"
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.lb.arn_suffix, { label = "RequestCount" }],
          ]
        }
      },
    ]
  })
}
