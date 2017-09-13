output "remote_state_backend_locker_id" {
  value = "${module.remote_state_backend.state_locker_id}"
}

output "remote_state_backend_logs_storage_id" {
  value = "${module.remote_state_backend.state_logs_storage_id}"
}

output "remote_state_backend_storage_id" {
  value = "${module.remote_state_backend.state_storage_id}"
}
