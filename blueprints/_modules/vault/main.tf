locals {
  name = "${var.prefix_env == "true" ? "${var.app}-${var.env}" : var.app}"

  common_tags = {
    App = "${var.app}"
    Env = "${var.env}"
  }
}

data "template_file" "vault_install_script" {
  template = "${file("${path.module}/scripts/vault.install.sh")}"

  vars {
    download_url        = "${var.vault_download_url}"
    additional_cmds     = "${var.vault_install_cmds}"
    vault_config        = "${file("${path.module}/scripts/vault_config.hcl")}"
    systemd_settings    = "${file("${path.module}/scripts/vault.service")}"
    pre_start_script    = "${file("${path.module}/scripts/vault.pre_start.sh")}"
    post_start_script   = "${file("${path.module}/scripts/vault.post_start.sh")}"
    user_session_script = "${file("${path.module}/scripts/vault.session.sh")}"
  }
}

# Individual server node configuration
resource "aws_launch_configuration" "vault" {
  name_prefix = "${local.name}-vault"

  image_id        = "${var.server_image}"
  instance_type   = "${var.server_class}"
  key_name        = "${var.ssh_key_name}"
  security_groups = ["${aws_security_group.server.id}"]
  user_data       = "${data.template_file.vault_install_script.rendered}"
}

# Auto-scaling configuration
resource "aws_autoscaling_group" "vault" {
  name = "${local.name}-vault"

  min_size         = "${var.min_nodes}"
  max_size         = "${var.max_nodes}"
  desired_capacity = "${var.min_nodes}"

  health_check_type         = "EC2"
  health_check_grace_period = 15

  load_balancers       = ["${aws_elb.vault.id}"]
  vpc_zone_identifier  = ["${split(",", var.subnet_ids)}"]
  launch_configuration = "${aws_launch_configuration.vault.name}"

  tag {
    key                 = "App"
    value               = "${var.app}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Env"
    value               = "${var.env}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${local.name}"
    propagate_at_launch = true
  }
}

# Load balancer
resource "aws_elb" "vault" {
  name = "${local.name}-vault"

  # ensure in-flight requests to unhealthy/deregistering nodes run to completion
  connection_draining         = true
  connection_draining_timeout = 400

  # internal-facing nodes are not accessible by the internet (think carefully)
  internal = "${var.public_facing == "false" ? true : false}"

  subnets         = ["${split(",", var.subnet_ids)}"]
  security_groups = ["${aws_security_group.load_balancer.id}"]

  # HTTP
  listener {
    instance_port     = 8200
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

  # HTTPS
  listener {
    instance_port     = 8200
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }

  # healthchecking (endpoint exposed by Vault itself; thanks Hashicorp)
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    target              = "${var.healthcheck_endpoint}"
    interval            = 15
  }

  tags = "${merge(local.common_tags, map("Name", local.name))}"
}

# ------------------------------------------------------------------------------
# SECURITY GROUPS
# ------------------------------------------------------------------------------

resource "aws_security_group" "server" {
  name        = "${local.name}-vault-server"
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
  name        = "${local.name}-vault-load-balancer"
  description = "vault load balancer rules"
  vpc_id      = "${var.vpc_id}"

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
