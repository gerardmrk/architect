/*
 * Private subnetworks:
 *   - netmask = /19
 *   - available IPv4s = 8167
 *
 * 'Public' subnetworks:
 *   - netmask = /20
 *   - available IPv4s = 4091
 *   - subdivided into 2 child subnetworks:
 *     - the actual public subnetwork itself
 *     - a 'spare' subnetwork
 */

# private subnet [AZ a]
resource "aws_subnet" "private_a" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${data.aws_availability_zones.main.names[0]}"
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 3, 0)}"

  tags = "${merge(local.common_tags, map("Name", "${var.app}_private_a"))}"
}

# public subnet [AZ a]
resource "aws_subnet" "public_a" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${data.aws_availability_zones.main.names[0]}"
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 4, 2)}"

  tags = "${merge(local.common_tags, map("Name", "${var.app}_public_a"))}"
}

# private subnet [AZ b]
resource "aws_subnet" "private_b" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${data.aws_availability_zones.main.names[1]}"
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 3, 2)}"

  tags = "${merge(local.common_tags, map("Name", "${var.app}_private_b"))}"
}

# public subnet [AZ b]
resource "aws_subnet" "public_b" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${data.aws_availability_zones.main.names[1]}"
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 4, 6)}"

  tags = "${merge(local.common_tags, map("Name", "${var.app}_public_b"))}"
}

# private subnet [AZ c]
resource "aws_subnet" "private_c" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${data.aws_availability_zones.main.names[2]}"
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 3, 4)}"

  tags = "${merge(local.common_tags, map("Name", "${var.app}_private_c"))}"
}

# public subnet [AZ c]
resource "aws_subnet" "public_c" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${data.aws_availability_zones.main.names[2]}"
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 4, 10)}"

  tags = "${merge(local.common_tags, map("Name", "${var.app}_public_c"))}"
}
