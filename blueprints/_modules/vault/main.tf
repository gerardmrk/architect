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

# Load balancer
resource "aws_elb" "vault" {
  name = "vault-elb"

  # ensure in-flight requests to unhealthy/deregistering nodes run to completion
  connection_draining = true
  connection_draining_timeout = 400

  # internal-facing nodes are not accessible by the internet (think carefully)
  internal = "${var.public_facing == "false" ? true : false}"

  subnets = "${var.subnet_ids}"
  security_groups = "${aws_security_groups.load_balancer.id}"

  # HTTP
  listener {
    instance_port = 8200
    instance_protocol = "tcp"
    lb_port = 80
    lb_protocol = "tcp"
  }

  # HTTPS
  listener {
    instance_port = 8200
    instance_protocol = "tcp"
    lb_port = 443
    lb_protocol = "tcp"
  }

  # healthchecking (endpoint exposed by Vault itself; thanks Hashicorp)
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 3
    timeout = 5
    target = "${var.healthcheck_endpoint}"
    interval = 20
  }
}


# ------------------------------------------------------------------------------
# SECURITY GROUPS
# ------------------------------------------------------------------------------

resource "aws_security_group" "server" {
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

resource "aws_security_group" "load_balancer" {
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
