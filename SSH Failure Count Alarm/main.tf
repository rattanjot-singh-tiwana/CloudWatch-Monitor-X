variable "region" {
  type        = string
  default     = "us-east-1"
  description = "aws default region"
}

# ------------------ PROVIDER ------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.7.0"
    }
  }
}

provider "aws" {
  region = var.region # Replace with your desired AWS region
}


# ------------------ VPC ------------------

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ------------------ EC2 ------------------

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical owner ID for Ubuntu AMIs

  filter {
    name   = "name"
    values = ["ubuntu/images/*/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group - Allow SSH and HTTP
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "app1" {
  key_name   = "app1"
  public_key = tls_private_key.key.public_key_openssh
}

# store private key in a file
resource "local_file" "private_key" {
  content  = tls_private_key.key.private_key_pem
  filename = "/root/.ssh/app1.pem"
  file_permission = "400"
}

# EC2 Instance 1 - t2.small
resource "aws_instance" "app1" {
  ami           = data.aws_ami.ubuntu.id # Replace with your desired AMI ID
  instance_type = "t2.small"
  subnet_id     = data.aws_subnets.default.ids[0]

  security_groups = [aws_security_group.allow_tls.id]

  root_block_device {
    volume_size = 10
  }
  user_data = filebase64("${path.module}/userdata_1.sh")

  key_name = "app1"
  associate_public_ip_address = true

  tags = {
    Name = "app1"
  }
}