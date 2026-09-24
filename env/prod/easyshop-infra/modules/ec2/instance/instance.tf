###################################### EC2 Instance ##############################################

resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3a.medium"
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id              = var.subnet_id
  key_name               = "lab-jayce"

  root_block_device {
    delete_on_termination = true
    iops                  = 3000
    volume_size           = 40
    volume_type           = "gp3"
    encrypted             = true
    kms_key_id            = var.kms_key_id
  }

  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type             = "persistent"
      instance_interruption_behavior = "stop"
    }
  }

  user_data                   = file("${path.module}/user_data.sh")
  user_data_replace_on_change = true
  iam_instance_profile        = aws_iam_instance_profile.ec2.name

  depends_on = [aws_security_group.ec2]

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}"
    Module = "${path.module}"
  })

  lifecycle {
    ignore_changes = [user_data]
  }
}
