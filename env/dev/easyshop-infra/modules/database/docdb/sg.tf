######################## SECURITY GROUP ########################

resource "aws_security_group" "sg_db" {
  name        = "${var.project.env}-${var.project.name}-docdb"
  description = "${var.project.env}-${var.project.name}-docdb"
  vpc_id      = var.docdb_vpc_id

  ingress {
    from_port       = 27017
    to_port         = 27017
    protocol        = "TCP"
    security_groups = var.docdb_allowed_sg
    description     = "Allow security groups to access DocumentDB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-docdb"
    Module = "${path.module}"
  })
}
