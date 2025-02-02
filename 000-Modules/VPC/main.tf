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
  for_each = { for idx, subnet_id in aws_subnet.public-subnets : idx => subnet_id.id }
  subnet_id      = each.value
  route_table_id = aws_route_table.aws-public-rt.id
  depends_on = [ aws_subnet.public-subnets, aws_route_table.aws-public-rt ]
}

resource "aws_route_table_association" "aws-private-rt-association" {
  for_each = { for idx, subnet_id in aws_subnet.private-subnets : idx => subnet_id.id }
  subnet_id      = each.value
  route_table_id = aws_route_table.aws-private-rt.id
  depends_on = [ aws_subnet.private-subnets, aws_route_table.aws-private-rt ]
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

output "az_and_subnet" {
  value = {
    az     = aws_subnet.public-subnets[0].availability_zone
    subnet = aws_subnet.public-subnets[0].id
  }
}

