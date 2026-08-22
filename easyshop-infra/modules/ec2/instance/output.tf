######################## EC2 Instance OUTPUT ###########################

output "sg_id" {
  value = aws_security_group.ec2.id
}

output "instance_id" {
  value = aws_instance.ec2.id
}

output "public_ip" {
  value = aws_eip.ec2.public_ip
}

output "private_ip" {
  value = aws_instance.ec2.private_ip
}

output "role_arn" {
  value       = aws_iam_role.ec2.arn
  description = "ARN of the ec2 instance IAM role"
}

output "instance_arn" {
  value       = aws_instance.ec2.arn
  description = "ARN of the ec2 instance"
}

output "ci_provider_role_arn" {
  value       = aws_iam_role.ci_provider.arn
  description = "ARN of the GitHub CI provider IAM role (OIDC + EC2 assume)"
}

output "oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.github.arn
  description = "ARN of the GitHub OIDC provider"
}
