provider "aws" {
  access_key = "${var.cloud_access_key}"
  secret_key = "${var.cloud_secret_key}"
  region     = "${var.cloud_region}"
}

# Remote state backend
module "remote_state_backend" {
  source = "./modules/remote_state_backend"

  app_name = "${var.app_name}"
  region   = "${var.cloud_region}"
}
