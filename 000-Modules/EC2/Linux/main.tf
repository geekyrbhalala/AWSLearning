# # EC2 Instance

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

resource "aws_instance" "aws_linux_instance" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instanceType
  associate_public_ip_address = var.associatePublicIPAddress
  availability_zone           = var.availabilityZone
  key_name                    = var.keyName
  vpc_security_group_ids      = var.securityGroupIds
  subnet_id = var.subnetId
  user_data = var.userData
  # if webpage doen't show up then use command "trail -3000 /var/log/cloud-init-output.log"

  tags = {
    Name        = var.instanceName
    ProjectCode = var.projectCode
  }
}

variable "projectCode" {
  type        = string
  description = "Project Code"
}

variable "instanceType" {
  type        = string
  description = "Instance Type"
  default = "t2.micro"
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
  default = ""
}

variable "instanceName" {
  type        = string
  description = "Instance Name" 
}