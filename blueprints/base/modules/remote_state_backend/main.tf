locals {
  spinalcase_name_prefix = "${lower(replace(trimspace(var.app_name), " ", "-"))}"
  pascalcase_name_prefix = "${replace(title(trimspace(var.app_name)), " ", "")}"
}

# State Locker
resource "aws_dynamodb_table" "iac_state_lock" {
  name           = "${local.pascalcase_name_prefix}IacStateLock"
  read_capacity  = 5
  write_capacity = 5

  hash_key = "LockID"

  lifecycle {
    prevent_destroy = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    App     = "${var.app_name}"
    Context = "IAC"
  }
}

# State Logs
resource "aws_s3_bucket" "iac_state_access_logs" {
  bucket = "${local.spinalcase_name_prefix}-iac-state-access-logs"
  region = "${var.region}"
  acl    = "log-delivery-write"

  lifecycle {
    prevent_destroy = true
  }

  lifecycle_rule {
    id      = "iac-state-logs-retention"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 60
    }

    tags {
      App     = "${var.app_name}"
      Context = "IAC"
    }
  }

  tags {
    App     = "${var.app_name}"
    Context = "IAC"
  }
}

# State Storage
resource "aws_s3_bucket" "iac_state_storage" {
  bucket        = "${local.spinalcase_name_prefix}-iac-state-storage"
  acl           = "private"
  region        = "${var.region}"
  force_destroy = false
  request_payer = "Requester"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${aws_s3_bucket.iac_state_access_logs.id}"
  }

  tags {
    App     = "${var.app_name}"
    Context = "IAC"
  }

  depends_on = [
    "aws_dynamodb_table.iac_state_lock",
    "aws_s3_bucket.iac_state_access_logs",
  ]

  provisioner "local-exec" {
    command = <<EOF
architect remotestate \
  --config-path='config.tf' \
  --app-name=${var.app_name} \
  --storage-id=${aws_s3_bucket.iac_state_storage.id} \
  --storage-key=base/terraform.tfstate \
  --storage-region=${aws_s3_bucket.iac_state_storage.region} \
  --lock-id=${aws_dynamodb_table.iac_state_lock.id} \
  --cleanup-local \
  --script-invocation
EOF
  }
}
