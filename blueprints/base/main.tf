provider "aws" {
  access_key = "${var.cloud_access_key}"
  secret_key = "${var.cloud_secret_key}"
  region     = "${var.cloud_region_code}"
}

locals {
  # --- [META] ---
  # app name prefix for service/resource IDs different conventions
  _trimmed = "${trimspace(var.app_name)}"

  _lowercased        = "${lower(local._trimmed)}"
  _titlecased        = "${title(local._trimmed)}"
  _spinalcase_prefix = "${replace(local._lowercased, " ", "-")}"
  _snakecase_prefix  = "${replace(local._lowercased, " ", "_")}"
  _pascalcase_prefix = "${replace(local._titlecased, " ", "")}"

  # --- [RESOURCE TAGS] ---
  # resource tags for globally-scoped resources and services
  global_tags = {
    App     = "${var.app_name}"
    Scope   = "global"
    Creator = "iac"
  }

  iac_tags     = "${merge(local.global_tags, map("Ctx", "iac_mgmt"))}"
  secrets_tags = "${merge(local.global_tags, map("Ctx", "secrets_mgmt"))}"

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
    prefix  = "${local.tmp_logs_prefix}"
    enabled = true
    tags    = "${local.global_tags}"

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

  # declare artificial dependency on the state-locking service to ensure it
  # has already been created by the time the provisioner command is run.
  depends_on = [
    "aws_s3_bucket.global_logs_storage",
    "aws_dynamodb_table.iac_state_lock_svc",
  ]

  # automate steps to
  # 1. generate new config file for remote backend
  # 2. reinitialize terraform in the current ('default') workspace
  # 3. migrate existing local state to the remote backend
  # 4. remove local state
  provisioner "local-exec" {
    command = <<EOF
architect remotestate \
  --config-path='config.tf' \
  --app-name=${var.app_name} \
  --storage-id=${aws_s3_bucket.iac_state_storage.id} \
  --storage-key=base/terraform.tfstate \
  --storage-region=${aws_s3_bucket.iac_state_storage.region} \
  --lock-id=${aws_dynamodb_table.iac_state_lock_svc.id} \
  --cleanup-local \
  --script-invocation
EOF
  }
}
