provider "aws" {
  access_key = "${var.cloud_access_key}"
  secret_key = "${var.cloud_secret_key}"
  region     = "${var.cloud_region_code}"
}

locals {
  # --- [META] ---
  # app name prefix for service/resource IDs of different conventions
  _trimmed = "${trimspace(var.app_name)}"

  _lowercased        = "${lower(local._trimmed)}"
  _titlecased        = "${title(local._trimmed)}"
  _spinalcase_prefix = "${replace(local._lowercased, " ", "-")}"
  _snakecase_prefix  = "${replace(local._lowercased, " ", "_")}"
  _pascalcase_prefix = "${replace(local._titlecased, " ", "")}"

  # --- [RESOURCE TAGS] ---
  # resource tags for globally-scoped resources and services
  global_tags = {
    App       = "${var.app_name}"
    Scope     = "global"
    CreatedBy = "iac"
  }

  iac_tags     = "${merge(local.global_tags, map("Context", "iac_mgmt"))}"
  secrets_tags = "${merge(local.global_tags, map("Context", "secrets_mgmt"))}"

  # --- [SERVICE IDS] ---

  # storage service ID for application logs
  logs_storage_id       = "${local._spinalcase_prefix}-application-logs"
  iac_state_lock_svc_id = "${local._pascalcase_prefix}IacStateLockSvc"
  iac_state_storage_id  = "${local._spinalcase_prefix}-iac-state"

  # --- [RESOURCE IDS] ---

  # logs storage sub-paths
  tmp_logs_prefix = "tmp/"
  iac_logs_prefix = "iac/"
}

# Global logs storage service
resource "aws_s3_bucket" "global_logs_storage" {
  bucket = "${local.logs_storage_id}"
  tags   = "${local.global_tags}"
  region = "${var.cloud_region_code}"
  acl    = "log-delivery-write"

  lifecycle {
    prevent_destroy = false
  }

  # Retention rule for debugging logs (tmp/*)
  lifecycle_rule {
    id      = "${local.logs_storage_id}-tmp"
    tags    = "${local.global_tags}"
    prefix  = "${local.tmp_logs_prefix}"
    enabled = true

    expiration {
      # permanently delete after 24 hours
      days = 1
    }
  }

  # Retention rule for IAC MGMT logs (iac/*)
  lifecycle_rule {
    id      = "${local.logs_storage_id}-iac"
    tags    = "${local.iac_tags}"
    prefix  = "${local.iac_logs_prefix}"
    enabled = true

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

# Global remote IAC state-locking service
resource "aws_dynamodb_table" "iac_state_lock_svc" {
  name           = "${local.iac_state_lock_svc_id}"
  tags           = "${local.iac_tags}"
  read_capacity  = 4
  write_capacity = 4

  hash_key = "LockID"

  lifecycle {
    prevent_destroy = false
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Global remote IAC state storage
resource "aws_s3_bucket" "iac_state_storage" {
  bucket        = "${local.iac_state_storage_id}"
  tags          = "${local.iac_tags}"
  acl           = "private"
  region        = "${var.cloud_region_code}"
  request_payer = "Requester"

  lifecycle {
    prevent_destroy = false
  }

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${aws_s3_bucket.global_logs_storage.id}"
    target_prefix = "${local.iac_logs_prefix}"
  }
}

# Local config file for the default workspace's remote state backend
resource "local_file" "remote_state_config" {
  # generate new config file for remote backend
  content = <<EOF
# [${var.app_name}] main remote state backend
terraform {
  backend "s3" {
    bucket         = "${aws_s3_bucket.iac_state_storage.id}"
    key            = "base/terraform.tfstate"
    region         = "${var.cloud_region_code}"
    dynamodb_table = "${aws_dynamodb_table.iac_state_lock_svc.id}"
  }
}
EOF

  # write file to the current module directory
  filename = "${path.module}/config.tf"
}

# Post config-update tasks
resource "null_resource" "post_state_config_update" {
  depends_on = [
    "local_file.remote_state_config",
  ]

  # reinitialize state backend for the default workspace.
  # this migrates the existing local state to remote
  provisioner "local-exec" {
    command    = "terraform init -force-copy"
    on_failure = "continue"
  }

  # remove existing local state files
  provisioner "local-exec" {
    command    = "rm -rf terraform.tfstate terraform.tfstate.backup"
    on_failure = "continue"
  }
}
