provider "aws" {
  access_key = "${var.cloud_access_key}"
  secret_key = "${var.cloud_secret_key}"
  region     = "${var.cloud_region}"
}

# Secrets Server

# State Logs
resource "aws_s3_bucket" "iac_state_access_logs" {
  bucket = "${lower(replace(trimspace(var.app_name), " ", "-"))}-iac-state-access-logs"
  region = "${var.cloud_region}"
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
  bucket        = "${lower(replace(trimspace(var.app_name), " ", "-"))}-iac-state-storage"
  acl           = "private"
  region        = "${var.cloud_region}"
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
}

# State Locker
resource "aws_dynamodb_table" "iac_state_lock" {
  name           = "${replace(title(trimspace(var.app_name)), " ", "")}IacStateLock"
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
