output "vpc_id" {
  value = "${aws_vpc.mod.id}"
}

output "subnets" {
  value = "${map(
    "a_private", "${map(
      "id", aws_subnet.a_private.id,
      "az", aws_subnet.a_private.availability_zone,
      "cidr", aws_subnet.a_private.cidr_block
    )}",
    "a_public", "${map(
      "id", aws_subnet.a_public.id,
      "az", aws_subnet.a_public.availability_zone,
      "cidr", aws_subnet.a_public.cidr_block
    )}",
    "b_private", "${map(
      "id", aws_subnet.b_private.id,
      "az", aws_subnet.b_private.availability_zone,
      "cidr", aws_subnet.b_private.cidr_block
    )}",
    "b_public", "${map(
      "id", aws_subnet.b_public.id,
      "az", aws_subnet.b_public.availability_zone,
      "cidr", aws_subnet.b_public.cidr_block
    )}",
    "c_private", "${map(
      "id", aws_subnet.c_private.id,
      "az", aws_subnet.c_private.availability_zone,
      "cidr", aws_subnet.c_private.cidr_block
    )}",
    "c_public", "${map(
      "id", aws_subnet.c_public.id,
      "az", aws_subnet.c_public.availability_zone,
      "cidr", aws_subnet.c_public.cidr_block
    )}"
  )}"
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
