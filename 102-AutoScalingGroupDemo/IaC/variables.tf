variable "project_code" {
  description = "Code to identify resources in the project"
  default     = "102"
}

variable "aws_region" {
  description = "The AWS region to create resources"
  default     = "ca-central-1"
}

variable "key_name" {
  description = "SSH key name"
  default     = "aws-ec2-instance-key"
}

variable "launch_template_name" {
  default = "auto-scale-launch-template"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "vpc_name" {
  type        = string
  description = "The AWS VPC name"
  default     = "auto-scale-vpc"
}

variable "main_cidr_block" {
  type        = string
  description = "The CIDR block of main vpc. i.e. 10.0.0.0/16"
  default     = "12.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  type        = list(string)
  description = "List of CIDR block of public subnet. i.e. [10.0.1.0/24,10.0.2.0/24]"
  default     = ["12.0.1.0/24", "12.0.2.0/24"]
}
variable "private_subnet_cidr_block" {
  type        = list(string)
  description = "List of CIDR block of private subnet. i.e. [10.0.1.0/24,10.0.2.0/24]"
  default     = ["12.0.3.0/24", "12.0.4.0/24"]
}