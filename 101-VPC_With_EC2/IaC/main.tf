# Step -1 
# Run following command into command prompt
# setx AWS_ACCESS_KEY_ID "<AWS_Access_Key_id>"
# setx AWS_SECRET_ACCESS_KEY "<AWS_Secret_Access_Key>"
provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../../000-Modules/VPC"
  vpcName = var.vpc_name
  cidrBlock = var.main_cidr_block
  projectCode = var.project_code
  subnetCIDRBlocks = var.subnet_cidr_block
  availabilityZones = var.availability_zones
}



module "ec2" {
  source                   = "../../000-Modules/EC2/Linux"
  instanceType             = var.instance_type
  associatePublicIPAddress = true
  availabilityZone         = "us-east-1a"
  keyName                  = var.key_name
  securityGroupIds         = [aws_security_group.allow_tls.id]
  subnetId                 = aws_subnet.aws-demo-public-subnet-1.id
  userData                 = file("linux-server-user-data.sh")
  instanceName             = "Linux-Public-Server"
  projectCode              = var.project_code
}
