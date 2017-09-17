variable "app" {
  description = "Application name for resource-grouping"
}

# If 'prefix_env' option is enabled, consider using a short env name or an short
# form or its abbreviation (e.g. dev, uat, pro), or else service names will be
# too verbose when looking at it from the console
variable "env" {
  description = "Environment scope for resource-grouping"
}

# Useful if you have all 3 environments in the same cloud account, and in the
# same region as well (disable it otherwise, as service names will be too verbose)
variable "prefix_env" {
  description = "Whether to add env to name prefix (true or false)"
  default     = "true"
}

# Pick a CIDR that is unique to the region in the event you'd want VPC-peering,
# as identical CIDR range cannot overlap
variable "cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

# Be aware that setting this to 'dedicated' will cost you more
variable "tenancy_type" {
  description = "VPC tenancy type (default or dedicated)"
  default     = "default"
}

# Useful for setting to a non-default port number so harder to breach by
# scripted bots that crawls the default port
variable "ssh_port" {
  description = "SSH port number for any server instances"
  default     = 22
}

# Use this to only limit access from your personal/work IP(s)
variable "ssh_ips" {
  type        = "list"
  description = "List of allowed IPs for SSH"
  default     = ["0.0.0.0/0"]
}
