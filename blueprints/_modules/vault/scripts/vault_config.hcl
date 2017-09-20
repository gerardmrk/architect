listener "tcp" {
  address = "${tcp_address}"
  tls_disable = "${tls_disable}"
}

storage "s3" {
  bucket = "${storage_id}"
  region = "${storage_region}"
  access_key = "${access_key}"
  secret_key = "${secret_key}"
}
