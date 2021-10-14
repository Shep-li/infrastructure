terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  shared_credentials_file = "/Users/asus/.aws/credentials"
  profile = "prod"
  region  = "us-east-1"
}


resource "aws_vpc" "default" {
  cidr_block           = "172.${var.cidr_numeral}.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_eip" "nat" {
  count = "${length(split(",", "${var.availability_zones}"))}"
  vpc   = true
}

resource "aws_nat_gateway" "nat" {
  count  = "${length(split(",", "${var.availability_zones}"))}"

  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
}

# PUBLIC SUBNETS
# The public subnet is where the bastion, NATs and ELBs reside. In most cases,
# there should not be any servers in the public subnet.

resource "aws_subnet" "public" {
  count  = "${length(split(",", "${var.availability_zones}"))}"
  vpc_id = "${aws_vpc.default.id}"

  cidr_block              = "10.${var.cidr_numeral}.${lookup(var.cidr_numeral_public, count.index)}.0/24"
  availability_zone       = "${element(split(",", var.availability_zones), count.index)}"
  map_public_ip_on_launch = true

}

# PUBLIC SUBNETS - Default route
#
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }
}

# PUBLIC SUBNETS - Route associations
#
resource "aws_route_table_association" "public" {
  count          = "${length(split(",", "${var.availability_zones}"))}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_instance" "app_server" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

