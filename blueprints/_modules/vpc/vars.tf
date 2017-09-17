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

variable "ssh_port" {
  description = "SSH port number for any server instances"
  default     = 22
}

variable "ssh_ips" {
  type        = "list"
  description = "List of allowed IPs for SSH"
  default     = ["0.0.0.0/0"]
}
