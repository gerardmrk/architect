output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "subnets" {
  value = "${module.vpc.subnets}"
}

output "route_table_private_id" {
  value = "${module.vpc.route_table_private_id}"
}

output "route_table_public_id" {
  value = "${module.vpc.route_table_public_id}"
}

output "security_group_id" {
  value = "${module.vpc.security_group_id}"
}

output "network_acl_id" {
  value = "${module.vpc.network_acl_id}"
}
