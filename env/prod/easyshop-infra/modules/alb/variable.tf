######################## VARIABLES ########################

#================ Project =================#
variable "project" {
  type        = map(any)
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

#================ ALB =================#
variable "alb_vpc_id" {
  type        = string
  description = "VPC ID for the ALB"
}

variable "alb_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for the ALB"
}

variable "services" {
  type        = map(any)
  description = "Service names keyed by services"
}
