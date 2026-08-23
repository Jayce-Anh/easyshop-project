############################### SECRET MANAGER VARIABLE ###############################

#================ Project =================#
variable "project" {
  type        = map(any)
  description = "Project configuration"
}

variable "tags" {
  type        = map(any)
  description = "Common tags applied to all resources"
}

#================= Variables =================#
variable "kms_key" {
  type        = string
  description = "KMS key ARN to encrypt secrets"
}

variable "secret_docdb" {
  type        = map(string)
  sensitive   = true
  description = "DocumentDB credentials"
}

variable "secret_cache" {
  type        = map(string)
  sensitive   = true
  description = "Cache credentials"
}