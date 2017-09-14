output "state_locker_id" {
  value       = "${aws_dynamodb_table.iac_state_lock.id}"
  description = "Remote state-locking service ID"
}

output "state_logs_storage_id" {
  value       = "${aws_s3_bucket.iac_state_access_logs.id}"
  description = "Remote state access logs storage ID"
}

output "state_storage_id" {
  value       = "${aws_s3_bucket.iac_state_storage.id}"
  description = "Remote state storage service ID"
}
