provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source                  = "../../000-Modules/VPC"
  vpcName                 = var.vpc_name
  cidrBlock               = var.main_cidr_block
  projectCode             = var.project_code
  publicSubnetCIDRBlocks  = var.public_subnet_cidr_block
  privateSubnetCIDRBlocks = var.private_subnet_cidr_block
  availabilityZones       = ["us-east-1a", "us-east-1b"]
}

resource "aws_security_group" "sg_allow_ssh_http" {
  name        = "${var.project_code}-sg_allow_ssh_http"
  description = "Allow tls,http traffic for web server"
  vpc_id      = module.vpc.vpc_id

  # Ingress rules: Allow HTTP traffic
  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rules: Allow SSH traffic
  ingress {
    description = "Allow HTTP traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rules: Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # "-1" means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    ProjectCode = var.project_code
  }
}

module "spot_launch_template" {
  source                   = "../../000-Modules/EC2/SpotInstanceTemplate"
  launchTemplateName       = var.launch_template_name
  projectCode              = var.project_code
  instanceType             = var.instance_type
  keyName                  = var.key_name
  associatePublicIPAddress = true
  availabilityZone         = module.vpc.az_and_subnet.az
  securityGroupIds         = [aws_security_group.sg_allow_ssh_http.id]
  subnetId                 = module.vpc.az_and_subnet.subnet
  userData                 = filebase64("linux-server-user-data.sh")
  instanceName             = "Linux-Public-Spot-Server"

  depends_on = [aws_security_group.sg_allow_ssh_http]
}

resource "aws_ec2_fleet" "spot_instances_fleet" {
  launch_template_config {
    launch_template_specification {
      launch_template_id = module.spot_launch_template.launch_template_id
      version            = "$Latest"
    }
  }

  target_capacity_specification {
    default_target_capacity_type = "spot"
    total_target_capacity        = 1
  }

  tags = {
    Name = "${var.project_code}-spot-instance"
  }

  depends_on = [module.spot_launch_template]
}