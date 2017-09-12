variable "cloud_access_key" {
  type        = "string"
  description = "Access key ID of your CSP"
}

variable "cloud_secret_key" {
  type        = "string"
  description = "Secret access key of CSP"
}

variable "cloud_region" {
  type        = "string"
  description = "Region to create your cloud services and resources in"
  default     = "us-east-1"
}

variable "app_name" {
  type        = "string"
  description = "Name of the app to prefix to each resource identifier"
}
