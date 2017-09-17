provider "aws" {
  access_key = "${var.cloud_access_key}"
  secret_key = "${var.cloud_secret_key}"
  region     = "${var.cloud_region_code}"
}

module "vpc" {
  source = "../_modules/vpc"
  name   = "sleepless_vpc"
  app    = "sleepless"
  env    = "development"
}
