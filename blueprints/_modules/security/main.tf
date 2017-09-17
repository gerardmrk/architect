# Basic security group for a standard Unix server
resource "aws_security_group" "server_basic" {
  vpc_id      = "${aws_vpc.main.id}"
  name        = "server_basic"
  description = "Basic rules for a standard Unix server"

  # allow http
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow https
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow SSH
  ingress {
    from_port   = "${var.ssh_port}"
    to_port     = "${var.ssh_port}"
    protocol    = "tcp"
    cidr_blocks = "${var.ssh_ips}"
  }

  # allow all outbound traffic for any protocol
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(local.common_tags, map("Name", var.app))}"
}
