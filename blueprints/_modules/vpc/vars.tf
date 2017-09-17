variable "name" {
  description = "Human-readable name of the VPC"
}

variable "app" {
  description = "Application name for resource-grouping"
}

variable "env" {
  description = "environment scope for resource-grouping"
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "tenancy_type" {
  description = "VPC tenancy type (default or dedicated)"
  default     = "default"
}
