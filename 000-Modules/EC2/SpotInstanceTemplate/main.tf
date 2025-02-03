data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"] # Owned by Amazon

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_launch_template" "template" {
  name = "${var.projectCode}-${var.launchTemplateName}"

  # Define the EC2 instance AMI and instance type
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instanceType

  # EC2 User Data
  user_data = var.userData

  # Network settings
  network_interfaces {
    associate_public_ip_address = var.associatePublicIPAddress
    security_groups = var.securityGroupIds
    subnet_id = var.subnetId
  }

  # Key Pair
  key_name = var.keyName

  # Tag the instance
  tags = {
    Name = "${var.projectCode}-${var.instanceName}"
    ProjectCode = var.projectCode
  }
}



variable "projectCode" {
  type        = string
  description = "Project Code"
}

variable "launchTemplateName" {
  type = string
  description = "Launch template name"
}

variable "instanceType" {
  type        = string
  description = "Instance Type"
}

variable "associatePublicIPAddress" {
  type        = bool
  description = "Associate Public IP Address"
  default = false
}

variable "availabilityZone" {
  type        = string
  description = "Availability Zone"
}

variable "keyName" {
  type        = string
  description = "Key Name"
}

variable "securityGroupIds" {
  type        = list(string)
  description = "Security Group IDs"
}

variable "subnetId" {
  type        = string
  description = "Subnet ID"
}

variable "userData" {
  type        = string
  description = "User Data"
}

variable "instanceName" {
  type        = string
  description = "Instance Name" 
}

output "launch_template_id" {
  value = aws_launch_template.template.id
}
