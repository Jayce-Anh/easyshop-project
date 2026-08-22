########################### TARGET GROUPS #####################################

#================== API services ======================#
resource "aws_lb_target_group" "auth" {
  name                 = "${var.project.env}-${var.project.name}-auth"
  port                 = 4000
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.alb_vpc_id
  deregistration_delay = 60

  health_check {
    interval            = 30
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200-499"
  }

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-auth"
    Module = "${path.module}"
  })
}

resource "aws_lb_target_group" "product" {
  name                 = "${var.project.env}-${var.project.name}-product"
  port                 = 5000
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.alb_vpc_id
  deregistration_delay = 60

  health_check {
    interval            = 30
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200-499"
  }

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-product"
    Module = "${path.module}"
  })
}

resource "aws_lb_target_group" "cart" {
  name                 = "${var.project.env}-${var.project.name}-cart"
  port                 = 6000
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.alb_vpc_id
  deregistration_delay = 60

  health_check {
    interval            = 30
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200-499"
  }

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-cart"
    Module = "${path.module}"
  })
}
