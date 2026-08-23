############################### VARIABLES ###############################

#================ Project =================#
variable "project" {
  type        = map(any)
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

#================ SQS =================#
variable "sqs_name" {
  type        = string
  default     = "sqs"
  description = "Suffix for the SQS queue name"
}

variable "kms_key" {
  type        = string
  description = "KMS key ARN for SQS message encryption"
}
