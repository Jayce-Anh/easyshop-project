########################### TARGET GROUPS #####################################

#================== API services ======================#
resource "aws_lb_target_group" "service" {
  for_each = var.services

  name                 = "${var.project.env}-${var.project.name}-${each.value.name}"
  port                 = each.value.port
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.alb_vpc_id
  deregistration_delay = 60

  health_check {
    interval            = 30
    path                = each.value.health_check != "" ? each.value.health_check : "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200-499"
  }

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-${each.value.name}"
    Module = "${path.module}"
  })
}
