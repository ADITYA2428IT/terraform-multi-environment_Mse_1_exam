# ==================================================
# CURRENT WORKSPACE
# ==================================================

output "workspace_name" {
  description = "Current Terraform workspace"
  value       = terraform.workspace
}


# ==================================================
# ENVIRONMENT
# ==================================================

output "environment" {
  description = "Current deployment environment"
  value       = var.environment
}


# ==================================================
# AWS REGION
# ==================================================

output "aws_region" {
  description = "AWS region used for deployment"
  value       = var.aws_region
}


# ==================================================
# VPC
# ==================================================

output "vpc_id" {
  description = "Default VPC discovered using data source"
  value       = data.aws_vpc.default.id
}


# ==================================================
# AVAILABILITY ZONES
# ==================================================

output "availability_zones" {
  description = "Available Availability Zones"
  value       = data.aws_availability_zones.available.names
}


# ==================================================
# EC2 INSTANCE IDs
# ==================================================

output "instance_ids" {
  description = "EC2 instance IDs"
  value       = aws_instance.web[*].id
}


# ==================================================
# PUBLIC IP ADDRESSES
# ==================================================

output "public_ips" {
  description = "Public IP addresses of EC2 instances"
  value       = aws_instance.web[*].public_ip
}


# ==================================================
# WEBSITE URLS
# ==================================================

output "website_urls" {
  description = "Website URLs"
  value = [
    for instance in aws_instance.web :
    "http://${instance.public_ip}"
  ]
}

