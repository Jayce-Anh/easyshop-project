############################### EC2 Instance VARIABLES ###############################

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
  description = "VPC ID for the EC2 instance"
}

variable "subnet_id" {
  type        = string
  description = "Private subnet ID for the EC2 instance"
}

variable "kms_key" {
  type        = string
  description = "KMS key ARN/ID for EBS encryption for the EC2 instance"
}

variable "cicd_git" {
  type = object({
    org    = string
    branch = string
    repos  = map(string)
  })
  description = "GitHub org, branch, and repo names used in the OIDC trust policy"
}