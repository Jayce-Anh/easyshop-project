######################## EC2 EIP #########################

resource "aws_eip" "ec2" {
  domain = "vpc"
  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-ec2"
    Module = "${path.module}"
  })
}

resource "aws_eip_association" "ec2" {
  instance_id   = aws_instance.ec2.id
  allocation_id = aws_eip.ec2.id
}
