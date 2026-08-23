######################## EXTERNAL ALB OUTPUT ########################

#================= ALB =================#
output "lb_arn" {
  description = "ARN of the external ALB"
  value       = aws_lb.lb.arn
}

output "lb_dns_name" {
  description = "DNS name of the ALB — used as CloudFront ALB origin"
  value       = aws_lb.lb.dns_name
}

output "lb_sg_id" {
  description = "Security group ID of the external ALB"
  value       = aws_security_group.sg_lb.id
}

output "lb_listener_http_arn" {
  description = "HTTP listener ARN"
  value       = aws_lb_listener.http.arn
}

#================= Target Group =================#

output "tg_arns" {
  description = "Target group ARNs by service name"
  value = {
    auth    = "${aws_lb_target_group.auth.arn}"
    product = "${aws_lb_target_group.product.arn}"
    cart    = "${aws_lb_target_group.cart.arn}"
  }
}
