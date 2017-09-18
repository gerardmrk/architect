locals {
  name = "${var.prefix_env == "true" ? "${var.app}-${var.env}" : var.app}"

  common_tags = {
    App = "${var.app}"
    Env = "${var.env}"
  }
}

resource "template_file" "vault_install_script" {
  template = "${file("${path.module}/scripts/vault.install.sh")}"

  var {
    download_url = "${var.vault_download_url}"
    config       = "${var.vault_config}"
    init_script = "${file("${path.module}/scripts/vault.init.sh")}"
    additional_cmds = "${var.vault_install_cmds}"
  }
}

resource "aws_launch_configuration" "vault" {
  image_id        = "${var.server_image}"
  instance_type   = "${var.server_class}"
  key_name        = "${var.ssh_key_name}"
  security_groups = []

  tags = "${merge(local.common_tags, map("Name", "${local.name}-vault-lc"))}"
}

resource "aws_autoscaling_group" "vault" {
  name               = "${aws_launch_configuration.vault.name}"
  availability_zones = "${var.server_az}"
  min_size           = "${var.min_nodes}"
  max_size           = "${var.max_nodes}"

  tags = "${merge(local.common_tags, map("Name", "${local.name}-vault-asg"))}"
}

# ------------------------------------------------------------------------------
# SECURITY GROUPS
# ------------------------------------------------------------------------------

resource "aws_security_group" "vault_server" {
  name        = "vault-server"
  description = "vault servers rule"
  vpc_id      = "${var.vpc_id}"

  # Allow SSH access
  ingress {
    from_port   = "${var.ssh_port}"
    to_port     = "${var.ssh_port}"
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_ssh_ips}"
  }

  # Allow Vault HTTP API access to each individual nodes for unsealing
  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(local.common_tags, map("Name", "${local.name}-vault-ec2"))}"
}

resource "aws_security_group" "vault_load_balancer" {
  name        = "vault-load-balancer"
  description = "vault load balancer rules"

  # HTTP traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS traffic
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(local.common_tags, map("Name", "${local.name}-vault-elb"))}"
}
