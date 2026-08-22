############################# ACM VARIABLE ##############################

#=============== Project ================#
variable "project" {
  type        = map(any)
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

#================ ACM =================#
variable "acm_hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for ACM DNS validation records"
}