/* -----------------------------------------------------------------------------
   Vault settings
 ---------------------------------------------------------------------------- */

variable "binary_download_url" {
  default = "https://releases.hashicorp.com/vault/0.8.2/vault_0.8.2_linux_amd64.zip"
  description = "Download URL for the Vault binary"
}


variable "secrets_config" {
  description = "Configuration (text) for Vault"
}

variable "additional_cmds" {
  default = ""
  description = "Additional commands to run in the install script"
}

/* -----------------------------------------------------------------------------
   AWS settings
 ---------------------------------------------------------------------------- */

variable "server_image" {
  description = "Image ID for the Vault instances (currently AWS AMI)"
}

variable "server_class" {
  description = "Server class/tier for the Vault instances (currently AWS EC2 instance types)"
}

variable "availability_zones" {
  description = "Availability zones for the Vault instances (currently AWS region codes)"
}

variable "healthcheck_endpoint" {
  description = "Health-check endpoint for the Vault instances (currently for AWS ELB)"
}

variable "nodes_count" {
  description = "Number of Vault instances"
}

variable "subnet_ids" {
  description = "List of subnets for the Vault instances in (currently AWS VPC subnets)"
}

variable "vpc_id" {
  description = "Cloud VPC ID for the Vault instances (currently AWS VPC)"
}

variable "ssh_key_pair" {
  description = "SSH key pair for the Vault instances"
}
