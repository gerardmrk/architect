output "loadbalancer_addr" {
  value = "${module.secrets_dev.loadbalancer_addr}"
}

output "key_fingerprint" {
  value = "${aws_key_pair.vault_dev.fingerprint}"
}
