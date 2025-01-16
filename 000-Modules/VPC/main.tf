resource "aws_vpc" "vpc" {
  cidr_block       = var.cidrBlock #"11.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name        = var.vpcName
    ProjectCode = var.projectCode
  }
}

resource "aws_subnet" "public-subnet-1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnetCIDRBlocks[0] #"11.0.1.0/24"
  availability_zone = var.availabilityZones[0]

  tags = {
    Name        = "${var.projectCode}-public-subnet-1"
    ProjectCode = var.projectCode
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnetCIDRBlocks[1] #"11.0.3.0/24"
  availability_zone = var.availabilityZones[1]

  tags = {
    Name        = "${var.projectCode}-public-subnet-2"
    ProjectCode = var.projectCode
  }
}

resource "aws_subnet" "private-subnet-1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnetCIDRBlocks[2] #"11.0.2.0/24"
  availability_zone = var.availabilityZones[2]

  tags = {
    Name        = "${var.projectCode}-private-subnet-1"
    ProjectCode = var.projectCode
  }
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnetCIDRBlocks[3] #"11.0.4.0/24"
  availability_zone = var.availabilityZones[3]

  tags = {
    Name        = "${var.projectCode}-private-subnet-2"
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
    Name        = "${var.projectCode}-public-rt"
    ProjectCode = var.projectCode
  }
}

resource "aws_route_table_association" "aws-public-rt_a1" {
  subnet_id      = aws_subnet.aws-public-subnet-1.id
  route_table_id = aws_route_table.aws-public-rt.id
}

resource "aws_route_table_association" "aws-public-rt_a2" {
  subnet_id      = aws_subnet.aws-public-subnet-3.id
  route_table_id = aws_route_table.aws-public-rt.id
}

resource "aws_route_table_association" "aws-private-rt_a3" {
  subnet_id      = aws_subnet.aws-private-subnet-2.id
  route_table_id = aws_route_table.aws-private-rt.id
}

resource "aws_route_table_association" "aws-private-rt_a4" {
  subnet_id      = aws_subnet.aws-private-subnet-4.id
  route_table_id = aws_route_table.aws-private-rt.id
}

resource "aws_security_group" "allow_tls" {
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
  securityGroupId = aws_security_group.allow_tls.id
}

variable "cidrBlock" {}
variable "vpcName" {}
variable "projectCode" {}

variable "subnetCIDRBlocks" {
  type = list(string)
}

variable "availabilityZones" {
  type = list(string)
}
