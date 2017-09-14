provider "aws" {
  access_key = "${var.cloud_access_key}"
  secret_key = "${var.cloud_secret_key}"
  region     = "${var.cloud_region_code}"
}

locals {
  # --- [META] ---
  _trimmed    = "${trimspace(var.app_name)}"
  _lowercased = "${lower(local._trimmed)}"
  _titlecased = "${title(local._trimmed)}"

  # app name prefix for service/resource IDs that mandates (or by convention):

  # > spinal-casing (e.g. S3: sleepless-iac-state-storage)
  _spinalcase_prefix = "${replace(local._lowercased, " ", "-")}"
  # > snake-casing (e.g. EC2:  sleepless_vault_node)
  _snakecase_prefix = "${replace(local._lowercased, " ", "_")}"
  # > pascal-casing (e.g. DynamoDB table: SleeplessIacStateLock)
  _pascalcase_prefix = "${replace(local._titlecased, " ", "")}"

  # --- [MAIN VARIABLES] ---

  # resource tags for globally-scoped resources and services
  global_tags = {
    App     = "${var.app_name}"
    Scope   = "global"
    Creator = "iac"
  }
  # resource tags for IAC-related resources and services
  iac_tags = "${merge(local.global_tags, map("Ctx", "iac_mgmt"))}"
  # resource tags for secrets-related resources and services
  secrets_tags = "${merge(local.global_tags, map("Ctx", "secrets_mgmt"))}"
  # storage service ID for application logs
  logs_storage_id = "${local._spinalcase_prefix}_application_logs"
  # storage path for IAC MGMT logs
  iac_logs_prefix = "iac"
  # storage path for debugging logs
  tmp_logs_prefix = "tmp"
}

# Global logs storage (currently: AWS S3 bucket)
resource "aws_s3_bucket" "global_logs_storage" {
  bucket = "${local.logs_storage_id}"
  region = "${var.cloud_region_code}"
  acl    = "log-delivery-write"
  tags   = "${local.global_tags}"

  lifecycle {
    prevent_destroy = true
  }

  # Retention rule for debugging logs (tmp/*)
  lifecycle_rule {
    id      = "${local.logs_storage_id}_${local.tmp_logs_prefix}"
    prefix  = "${local.tmp_logs_prefix}/"
    enabled = true
    tags    = "${local.global_tags}"

    expiration {
      # permanently delete after 24 hours
      days = 1
    }
  }

  # Retention rule for IAC MGMT logs (iac/*)
  lifecycle_rule {
    id      = "${local.logs_storage_id}_${local.iac_logs_prefix}"
    prefix  = "${local.iac_logs_prefix}/"
    enabled = true
    tags    = "${local.iac_tags}"

    # move log to IA storage (S3 Infrequent-Access class) after 30 days
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # permanently delete log after 3 months (+/-)
    expiration {
      days = 120
    }
  }
}

# Global remote IAC state backend (currently: AWS S3 Bucket, Amazon DynamoDB table)
module "remote_state_backend" {
  source = "../_modules/remote_state_backend"

  app_name = "${var.app_name}"
  region   = "${var.cloud_region_code}"
}
