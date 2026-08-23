############################### GITLAB RUNNER VARIABLES ###############################

variable "project" {
  type        = map(any)
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the GitLab runner"
}

variable "subnet_id" {
  type        = string
  description = "Public subnet ID for the GitLab runner"
}

variable "kms_key" {
  type        = string
  description = "KMS key ARN for EBS encryption for the GitLab runner"
}
