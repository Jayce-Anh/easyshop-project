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
  description = "GitHub org, shared branch, and per-service repo names"
}