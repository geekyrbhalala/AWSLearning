provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source                  = "../../000-Modules/VPC"
  vpcName                 = var.vpc_name
  cidrBlock               = var.main_cidr_block
  projectCode             = var.project_code
  publicSubnetCIDRBlocks  = var.public_subnet_cidr_block
  privateSubnetCIDRBlocks = var.private_subnet_cidr_block
  availabilityZones       = data.aws_availability_zones.available.names
}

#Create Launch Template for Auto Scaling Group
module "launch_template" {
  source             = "../../000-Modules/EC2/LaunchTemplate"
  launchTemplateName = var.launch_template_name
  projectCode        = var.project_code
  instanceType       = var.instance_type
  keyName            = var.key_name
  availabilityZone   = data.aws_availability_zones.available.names[0]
  securityGroupIds   = [module.vpc.security_group_id]
  subnetId           = module.vpc.public_subnet_ids[0]
  userData           = filebase64("linux-server-user-data.sh")
  instanceName       = "Linux-Public-Server"
}