####################### EC2 SECURITY GROUP #######################

resource "aws_security_group" "ec2" {
  vpc_id      = var.vpc_id
  description = "${var.project.env}-${var.project.name}-ec2"
  name        = "${var.project.env}-${var.project.name}-ec2"

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-ec2"
    Module = "${path.module}"
  })
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.ec2.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Allow all outbound for SSM, NAT, and AWS APIs"
  cidr_blocks       = ["0.0.0.0/0"]
}
