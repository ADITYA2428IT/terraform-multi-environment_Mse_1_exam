# ==================================================
# DATA SOURCE 1
# Available Availability Zones
# ==================================================

data "aws_availability_zones" "available" {
  state = "available"
}


# ==================================================
# DATA SOURCE 2
# Default VPC
# ==================================================

data "aws_vpc" "default" {
  default = true
}


# ==================================================
# DATA SOURCE 3
# Subnets in the Default VPC
# ==================================================

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name = "availability-zone"
    values = [
      "us-east-1a",
      "us-east-1b",
      "us-east-1c",
      "us-east-1d",
      "us-east-1f"
    ]
  }
}



# ==================================================
# DATA SOURCE 4
# Latest Ubuntu 22.04 AMI
# ==================================================

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ==================================================
# SECURITY GROUP
# ==================================================

resource "aws_security_group" "web_sg" {

  name = "${var.project_name}-${var.environment}-sg"

  description = "Security group for Terraform MSE web servers"

  vpc_id = data.aws_vpc.default.id


  # SSH access
  ingress {
    description = "SSH"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      var.allowed_ssh_cidr
    ]
  }


  # HTTP access
  ingress {
    description = "HTTP"

    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }


  # Outbound traffic
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }


  tags = {
    Name        = "${var.project_name}-${var.environment}-sg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# ==================================================
# EC2 INSTANCES
# ==================================================

resource "aws_instance" "web" {

  count = var.instance_count

  ami = data.aws_ami.ubuntu.id

  instance_type = var.instance_type

  subnet_id = data.aws_subnets.default.ids[
    count.index % length(data.aws_subnets.default.ids)
  ]

  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

  user_data = <<-EOF
              #!/bin/bash

              apt-get update -y

              apt-get install -y nginx

              systemctl enable nginx

              systemctl start nginx

              echo "<h1>${var.environment} Environment</h1>" > /var/www/html/index.html

              echo "<p>Created using Terraform</p>" >> /var/www/html/index.html

              echo "<p>Instance Number: ${count.index + 1}</p>" >> /var/www/html/index.html
              EOF

  tags = {
    Name        = "${var.project_name}-${var.environment}-server-${count.index + 1}"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

