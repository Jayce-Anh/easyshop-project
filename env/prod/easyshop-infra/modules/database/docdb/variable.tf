############################## VARIABLES ##############################

#========== Project ==========#
variable "project" {
  type        = map(any)
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

#============== DocumentDB ==============#
variable "docdb_vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "docdb_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the DocumentDB subnet group"
}

variable "docdb_allowed_sg" {
  type        = list(string)
  description = "List of allowed security group IDs to DocumentDB"
}

variable "kms_key" {
  type        = string
  description = "KMS key ARN"
}
