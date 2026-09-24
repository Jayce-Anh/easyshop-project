################################# SECRET MANAGER #################################

#================= App secrets =================#
# API Services
resource "aws_secretsmanager_secret" "api-service" {
  for_each = var.services

  name                    = "${var.project.env}-${var.project.name}-${each.value.name}"
  recovery_window_in_days = 0
  kms_key_id              = var.kms_key_id
  description             = "App env for ${each.value.name} API service"

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-${each.value.name}"
    Module = "${path.module}"
  })
}

# Web-UI
resource "aws_secretsmanager_secret" "web-ui" {
  name                    = "${var.project.env}-${var.project.name}-web-ui"
  recovery_window_in_days = 0
  kms_key_id              = var.kms_key_id
  description             = "App env for web-ui service"

  tags = merge(var.tags, {
    Name   = "${var.project.env}-${var.project.name}-web-ui"
    Module = "${path.module}"
  })
}

#================= Secret Version =================#
# API Services
resource "aws_secretsmanager_secret_version" "api-service" {
  for_each = aws_secretsmanager_secret.api-service

  secret_id     = each.value.id
  secret_string = jsonencode(merge(var.secret_docdb, var.secret_cache))

  lifecycle {
    ignore_changes = [secret_string]
  }
}