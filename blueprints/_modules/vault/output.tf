output "loadbalancer_addr" {
  value = "${aws_elb.vault.dns_name}"
}
