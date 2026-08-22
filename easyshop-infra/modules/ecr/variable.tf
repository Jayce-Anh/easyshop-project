############################ ECR VARIABLE ############################

#================ Project =================#
variable "project" {
  type        = map(any)
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

variable "kms_key_id" {
  type        = string
  description = "KMS key ARN for ECR image encryption"
}
