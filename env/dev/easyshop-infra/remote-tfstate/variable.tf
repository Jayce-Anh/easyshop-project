####################### S3 REMOTE STATE VARIABLE ##########################

variable "project" {
  type        = map(any)
  description = "Project configuration"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
}