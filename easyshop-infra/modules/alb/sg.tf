########################### LOAD BALANCER SECURITY GROUP ###########################

resource "aws_security_group" "sg_lb" {
  name        = "${var.project.env}-${var.project.name}-external"
  description = "SG of external ALB"
  vpc_id      = var.alb_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "Allow HTTP from CloudFront / internet"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-external"
    Module = "${path.module}"
  })
}
