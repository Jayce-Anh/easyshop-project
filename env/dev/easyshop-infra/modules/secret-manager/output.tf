############################## SECRET MANAGER OUTPUT ##############################

output "secret_id" {
  description = "Map of app secret IDs"
  value = merge(
    { for name, secret in aws_secretsmanager_secret.api-service : name => secret.id },
    { web-ui = "${aws_secretsmanager_secret.web-ui.id}" }
  )
}

output "secret_arn" {
  description = "Map of app secret ARNs"
  value = merge(
    { for name, secret in aws_secretsmanager_secret.api-service : name => secret.arn },
    { web-ui = "${aws_secretsmanager_secret.web-ui.arn}" }
  )
}
