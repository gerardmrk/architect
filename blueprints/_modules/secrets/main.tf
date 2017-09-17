resource "template_file" "install" {
  template = "${file("${path.module}/scripts/install.sh.tpl")}"

  var {
    download_url = "${var.vault_url}"
    config       = "${var.vault_config}"
  }
}

resource "aws_autoscaling_group" "vault" {}
