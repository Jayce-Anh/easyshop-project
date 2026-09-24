###################### ECS VARIABLE ######################

#============== Project ================#
variable "project" {
  type        = map(any)
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

#=============== ECS ================#
variable "ecs_lb_sg_id" {
  type        = string
  description = "Load balancer security group ID"
}

variable "ecs_target_group_arns" {
  type        = map(string)
  description = "Target group ARNs keyed by service name (auth, product, cart)"
}

variable "ecs_vpc_id" {
  type        = string
  description = "VPC ID for ECS service"
}

variable "ecs_subnets" {
  type        = list(string)
  description = "Subnets for ECS service"
}

variable "ecs_ecr_urls" {
  type        = map(string)
  description = "ECR repository URLs keyed by service name"
}

#=============== CloudWatch ================#
variable "ecs_cpu_alarm_threshold" {
  type        = number
  description = "ECS CPU utilization alarm threshold (percent)"
  default     = 50
}

variable "ecs_memory_alarm_threshold" {
  type        = number
  description = "ECS memory utilization alarm threshold (percent)"
  default     = 50
}

variable "alarm_emails" {
  type        = list(string)
  description = "Email addresses to subscribe to the ECS alarm SNS topic"
  default     = []
}