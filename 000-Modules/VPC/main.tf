resource "aws_vpc" "vpc" {
  cidr_block       = var.cidrBlock #"11.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name        = var.vpcName
    ProjectCode = var.projectCode
  }
}

resource "aws_subnet" "public-subnets" {
  count = length(var.publicSubnetCIDRBlocks)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.publicSubnetCIDRBlocks[count.index]
  availability_zone = var.availabilityZones[count.index]

  tags = {
    Name        = "${var.projectCode}-public-subnet-${count.index+1}"
    ProjectCode = var.projectCode
  }
}

resource "aws_subnet" "private-subnets" {
  count = length(var.privateSubnetCIDRBlocks)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.privateSubnetCIDRBlocks[count.index]
  availability_zone = var.availabilityZones[count.index]

  tags = {
    Name        = "${var.projectCode}-private-subnet-${count.index+1}"
    ProjectCode = var.projectCode
  }
}

resource "aws_internet_gateway" "aws-igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.projectCode}-igw"
    ProjectCode = var.projectCode
  }
}

resource "aws_route_table" "aws-public-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws-igw.id
  }

  tags = {
    Name        = "${var.projectCode}-public-rt"
    ProjectCode = var.projectCode
  }
}

resource "aws_route_table" "aws-private-rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.projectCode}-private-rt"
    ProjectCode = var.projectCode
  }
}

resource "aws_route_table_association" "aws-public-rt-association" {
  subnet_id      = aws_subnet.public-subnets[*].id
  route_table_id = aws_route_table.aws-public-rt.id
}

resource "aws_route_table_association" "aws-private-rt-association" {
  subnet_id      = aws_subnet.private-subnets[*].id
  route_table_id = aws_route_table.aws-private-rt.id
}

resource "aws_security_group" "sg-allow_tls" {
  name        = "allow_tls"
  vpc_id      = aws_vpc.vpc.id
  description = "Allow TLS inbound traffic and all outbound traffic"
  tags = {
    Name        = "${var.projectCode}-allow_tls"
    Description = "Allow TLS inbound traffic and all outbound"
    ProjectCode = var.projectCode
  }
}

module "egress_allow_all_traffic" {
  source = "./EgressRules/AllowAllTraffic"
  securityGroupId = aws_security_group.sg-allow_tls.id
}

module "ingress_allow_ssh_traffic" {
  source = "./IngressRules/AllowSSH_Port22"
  securityGroupId = aws_security_group.sg-allow_tls.id
}

module "ingress_allow_http_traffic" {
  source = "./IngressRules/AllowHTTP_Port80"
  securityGroupId = aws_security_group.sg-allow_tls.id
}


// Variables
variable "cidrBlock" {}
variable "vpcName" {}
variable "projectCode" {}

variable "publicSubnetCIDRBlocks" {
  type = list(string)
}

variable "privateSubnetCIDRBlocks" {
  type = list(string)
}

variable "availabilityZones" {
  type = list(string)
}


// Output variables
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public-subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private-subnets[*].id
}

output "security_group_id" {
  value = aws_security_group.sg-allow_tls.id
}

