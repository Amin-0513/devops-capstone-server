terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_vpc" "saa_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "saa-vpc" }
}

resource "aws_subnet" "saa_public_subnet" {
  vpc_id                  = aws_vpc.saa_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = { Name = "saa-public-subnet" }
}

resource "aws_internet_gateway" "saa_igw" {
  vpc_id = aws_vpc.saa_vpc.id

  tags = { Name = "saa-igw" }
}

resource "aws_route_table" "saa_public_rt" {
  vpc_id = aws_vpc.saa_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.saa_igw.id
  }

  tags = { Name = "saa-public-rt" }
}

resource "aws_route_table_association" "saa_public_assoc" {
  subnet_id      = aws_subnet.saa_public_subnet.id
  route_table_id = aws_route_table.saa_public_rt.id
}

resource "aws_security_group" "saa_sg" {
  name        = "saa-sg"
  description = "SSH, server port, and all traffic between server and client"
  vpc_id      = aws_vpc.saa_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "Server app port"
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana dashboard"
    from_port   = var.grafana_port
    to_port     = var.grafana_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "All traffic inside the VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "saa-sg" }
}

resource "aws_instance" "server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.saa_public_subnet.id
  vpc_security_group_ids = [aws_security_group.saa_sg.id]
  key_name               = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io docker-compose-v2 git
    systemctl enable --now docker
    usermod -aG docker ubuntu
  EOF

  tags = { Name = "saa-server" }
}
