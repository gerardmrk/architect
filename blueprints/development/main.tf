provider "aws" {
  access_key = "${var.cloud_access_key}"
  secret_key = "${var.cloud_secret_key}"
  region     = "${var.cloud_region_code}"
}

locals {
  app        = "rip"
  env        = "dev"
  prefix_env = "false"
}

# List all available availability zones from the region
data "aws_availability_zones" "az_dev" {}

# AWS key pair for node access
resource "aws_key_pair" "vault_dev" {
  key_name   = "${local.app}-${local.env}"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

module "network_dev" {
  source = "../_modules/vpc"

  app                = "${local.app}"
  env                = "${local.env}"
  prefix_env         = "${local.prefix_env}"
  cidr_block         = "10.0.0.0/16"
  tenancy_type       = "default"
  availability_zones = "${data.aws_availability_zones.az_dev.names}"
}

module "secrets_dev" {
  source = "../_modules/vault"

  app        = "${local.app}"
  env        = "${local.env}"
  prefix_env = "${local.prefix_env}"

  server_image = "ami-e2021d81"
  server_class = "t2.micro"
  server_az    = "${join(",", data.aws_availability_zones.az_dev.names)}"

  public_facing = "false"
  min_nodes     = 1
  max_nodes     = 3
  subnet_ids    = "${module.network_dev.private_subnet_ids}"
  vpc_id        = "${module.network_dev.vpc_id}"

  ssh_key_name = "${aws_key_pair.vault_dev.key_name}"
  ssh_port     = 22
}
