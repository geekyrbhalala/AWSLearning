variable "project_code" {
  description = "Code to identify resources in the project"
  default = "102"
}

variable "aws_region" {
  description = "The AWS region to create resources"
  default     = "us-east-1"
}

variable "key_name" {
  description = "SSH key name"
  default = "aws-ec2-instance-key"
}

