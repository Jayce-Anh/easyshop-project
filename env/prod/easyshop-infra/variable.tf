############################## VARIABLE VALUES ##############################

#=============== Project ================#
variable "project" {
  type        = map(any)
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

variable "cicd_git" {
  type = object({
    org    = string
    branch = string
    repos  = map(string)
  })
  description = "GitHub configuration for CI/CD pipeline"
}

#=============== Monitoring ================#
variable "alarm_emails" {
  type        = list(string)
  description = "Email addresses to subscribe to the CloudWatch alarm SNS topic"
}

#=============== Services ================#
variable "services" {
  type        = map(any)
  description = "Service names keyed by services"
}