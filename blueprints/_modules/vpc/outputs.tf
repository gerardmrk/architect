output "vpc_id" {
  value = "${aws_vpc.mod.id}"
}

output "private_subnet_ids" {
  value = [
    "${aws_subnet.a_private.id}",
    "${aws_subnet.b_private.id}",
    "${aws_subnet.c_private.id}"
  ]
}

output "public_subnet_ids" {
  value = [
    "${aws_subnet.a_public.id}",
    "${aws_subnet.b_public.id}",
    "${aws_subnet.c_public.id}"
  ]
}

output "route_table_private_id" {
  value = "${aws_default_route_table.private.id}"
}

output "route_table_public_id" {
  value = "${aws_route_table.public.id}"
}

output "security_group_id" {
  value = "${aws_default_security_group.mod.id}"
}

output "network_acl_id" {
  value = "${aws_default_network_acl.mod.id}"
}
