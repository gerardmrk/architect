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

variable "use_env_prefix" {
  type        = "string"
  description = "Whether to prefix stage/env to names of services and resources (useful if your environments are in the same cloud account)"
  default     = "true"
}
