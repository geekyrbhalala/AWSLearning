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
    subnet_id = var.subnetId
    security_groups = var.securityGroupIds
  }

  # IAM Instance Profile (optional)
  iam_instance_profile {
    name = var.iamInstanceProfileName
  }

  # Monitoring (optional)
  monitoring {
    enabled = var.enableMonitoring  # Enable CloudWatch monitoring
  }

  # Key Pair
  key_name = var.keyName

  # Block Device Mapping (optional)
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = var.volumeSize //optional
      volume_type = var.volumeType //optional
      delete_on_termination = var.deleteOnTermination //optional
    }
  }

  # Tag the instance
  tags = {
    Name = "${var.projectCode}-${var.instanceName}"
  }

  # Instance Metadata Options (optional)
  metadata_options {
    http_tokens = var.httpTokens  # Enforce the use of IAM roles with instance metadata
    http_endpoint = var.httpEndpoint  # Allow access to instance metadata
  }

  # Shutdown Behavior (optional)
  instance_initiated_shutdown_behavior = var.instanceInitiatedShutdownBehavior
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

variable "iamInstanceProfileName" {
  type        = string
  description = "IAM Instance Profile Name"
  default = null
}

variable "enableMonitoring" {
  description = "Enable or disable CloudWatch monitoring for the EC2 instance"
  type        = bool
  default     = true
}

variable "volumeSize" {
  description = "Size of the EBS volume (in GB)"
  type        = number
  default     = 8  # Replace with your desired volume size
}

variable "volumeType" {
  description = "Type of the EBS volume"
  type        = string
  default     = "gp3"  # Default to General Purpose SSD
}

variable "deleteOnTermination" {
  description = "Whether to delete the EBS volume on termination"
  type        = bool
  default     = true
}

variable "httpTokens" {
  description = "Whether to enforce the use of IAM roles for instance metadata"
  type        = string
  default     = "required"  # Options are "optional" or "required"
}

variable "httpEndpoint" {
  description = "Whether to allow access to instance metadata"
  type        = string
  default     = "enabled"  # Options are "enabled" or "disabled"
}

variable "instanceInitiatedShutdownBehavior" {
  description = "The shutdown behavior of the EC2 instance"
  type        = string
  default     = "terminate"  # Options are "stop" or "terminate"
}

output "launch_template_id" {
  value = aws_launch_template.template.id
}