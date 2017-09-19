# ------------------------------------------------------------------------------
# Meta
# ------------------------------------------------------------------------------

variable "app" {
  description = "Application name for resource-grouping"
}

variable "env" {
  description = "Environment scope for resource-grouping"
}

variable "prefix_env" {
  description = "Whether to add env to name prefix (true or false)"
  default     = "true"
}

# ------------------------------------------------------------------------------
# Vault
# ------------------------------------------------------------------------------

variable "vault_download_url" {
  default     = "https://releases.hashicorp.com/vault/0.8.2/vault_0.8.2_linux_amd64.zip"
  description = "Download URL for the Vault binary"
}

variable "vault_install_cmds" {
  default     = ""
  description = "Additional commands you'd like to run in the install script"
}

# ------------------------------------------------------------------------------
# Cloud
# ------------------------------------------------------------------------------

variable "server_image" {
  description = "Image ID for the Vault instances (currently AWS AMI)"
}

variable "server_class" {
  description = "Server class/tier for the Vault instances (currently AWS EC2 instance types)"
}

# important to consider: if this is for user-interactions (e.g. IAC secrets)
variable "public_facing" {
  description = "Whether the nodes are internet-facing (publicly-resolvable IPs)"
  default     = "false"
}

# this should reflect the 'public-facing' option: use public subnets if true
variable "server_az" {
  description = "Availability zones for the Vault instances (currently AWS region codes)"
}

# https://www.vaultproject.io/api/system/health.html
variable "healthcheck_endpoint" {
  description = "Health-check endpoint for the Vault instances"
  default     = "HTTP:8200/v1/sys/health"
}

variable "min_nodes" {
  description = "Minimum number of Vault instances"
  default     = "1"
}

variable "max_nodes" {
  description = "Maximum number of Vault instances"
  default     = "5"
}

variable "subnet_ids" {
  description = "List of subnets for the Vault instances in (currently AWS VPC subnets)"
}

variable "vpc_id" {
  description = "Cloud VPC ID for the Vault instances (currently AWS VPC)"
}

variable "ssh_key_name" {
  description = "SSH key pair for the Vault instances"
}

# Useful for setting to a non-default port number so harder to breach by
# scripted bots that crawls the default port
variable "ssh_port" {
  description = "SSH port number for any server instances"
  default     = 22
}

# Use this to only limit access from your personal/work IP(s)
variable "allowed_ssh_ips" {
  type        = "list"
  description = "List of allowed IPs for SSH"
  default     = ["0.0.0.0/0"]
}
