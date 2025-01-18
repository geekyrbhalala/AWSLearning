provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../../000-Modules/VPC"
  vpcName = var.vpc_name
  cidrBlock = var.main_cidr_block
  projectCode = var.project_code
  publicSubnetCIDRBlocks = var.public_subnet_cidr_block
  privateSubnetCIDRBlocks = var.private_subnet_cidr_block
  availabilityZones = var.availability_zones
}

module "ec2" {
  source                   = "../../000-Modules/EC2/Linux"
  instanceType             = var.instance_type
  associatePublicIPAddress = true
  availabilityZone         = var.availability_zones[0]
  keyName                  = var.key_name
  securityGroupIds         = [module.vpc.security_group_id]
  subnetId                 = module.vpc.public_subnet_ids[0]
  userData                 = file("linux-server-user-data.sh")
  instanceName             = "Linux-Public-Server"
  projectCode              = var.project_code
}
