variable "app_name" {
  type        = "string"
  description = "Name of the app to prefix to each resource identifier"
}

variable "region" {
  type        = "string"
  description = "Region to create your cloud services and resources in"
  default     = "us-east-1"
}
