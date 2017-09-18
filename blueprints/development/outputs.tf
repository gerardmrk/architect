output "vpc_id" {
  value = "${module.vpc_dev.vpc_id}"
}

output "subnets" {
  value = "${merge(module.vpc_dev.private_subnets, module.vpc_dev.public_subnets)}"
}

output "route_table_private_id" {
  value = "${module.vpc_dev.route_table_private_id}"
}

output "route_table_public_id" {
  value = "${module.vpc_dev.route_table_public_id}"
}

output "security_group_id" {
  value = "${module.vpc_dev.security_group_id}"
}

output "network_acl_id" {
  value = "${module.vpc_dev.network_acl_id}"
}
