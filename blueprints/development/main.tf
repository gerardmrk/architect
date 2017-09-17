provider "aws" {
  access_key = "${var.cloud_access_key}"
  secret_key = "${var.cloud_secret_key}"
  region     = "${var.cloud_region_code}"
}

module "vpc" {
  source       = "../_modules/vpc"
  app          = "sleepless"
  env          = "dev"
  cidr_block   = "10.0.0.0/16"
  tenancy_type = "default"
  ssh_port     = 22
  ssh_ips      = ["0.0.0.0/0"]
}
