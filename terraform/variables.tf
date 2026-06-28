variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for public subnet"
  type        = string
}
# Public Subnet 1c
variable "public_subnet_1c_cidr" {
  description = "CIDR block for public subnet in ap-northeast-1c"
  type        = string
}

# Private Subnet 1a
variable "private_subnet_1a_cidr" {
  description = "CIDR block for private subnet in ap-northeast-1a"
  type        = string
}

# Private Subnet 1c
variable "private_subnet_1c_cidr" {
  description = "CIDR block for private subnet in ap-northeast-1c"
  type        = string
}

# AZ 1c
variable "availability_zone_1c" {
  description = "Second Availability Zone"
  type        = string
}
variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}
