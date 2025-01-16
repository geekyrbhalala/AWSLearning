variable "project_code" {
  description = "Code to identify resources in the project"
  default     = "101"
}

variable "aws_region" {
  description = "The AWS region to create resources"
  default     = "us-east-1"
}

variable "key_name" {
  description = "SSH key name"
  default     = "aws-ec2-instance-key"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "vpc_name" {
  type = string
  description = "The AWS VPC name"
  default = "demo-vpc"
}

variable "main_cidr_block" {
  type = string
  description = "The CIDR block of main vpc. i.e. 10.0.0.0/16"
  default = "11.0.0.0/16"
}

variable "subnet_cidr_block" {
  type = list(string)
  description = "List of CIDR block of subnet. i.e. [10.0.1.0/24,10.0.2.0/24]"
  default = ["11.0.1.0/24", "11.0.2.0/24", "11.0.3.0/24", "11.0.4.0/24"]
}

variable "availability_zones" {
  type = list(string)
  description = "List of availability zones. i.e. [us-east-1a, us-east-1b]"
  default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
}