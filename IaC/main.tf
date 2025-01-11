# Step -1 
# Run following command into command prompt
# setx AWS_ACCESS_KEY_ID "<AWS_Access_Key_id>"
# setx AWS_SECRET_ACCESS_KEY "<AWS_Secret_Access_Key>"

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "demo-vpc" {
  cidr_block       = "11.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "demo-vpc"
  }
}

resource "aws_subnet" "aws-demo-public-subnet-1" {
  vpc_id            = aws_vpc.demo-vpc.id
  cidr_block        = "11.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "aws-demo-public-subnet-1"
  }
}

resource "aws_subnet" "aws-demo-public-subnet-3" {
  vpc_id            = aws_vpc.demo-vpc.id
  cidr_block        = "11.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "aws-demo-public-subnet-2"
  }
}

resource "aws_subnet" "aws-demo-private-subnet-2" {
  vpc_id            = aws_vpc.demo-vpc.id
  cidr_block        = "11.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "aws-demo-private-subnet-1"
  }
}

resource "aws_subnet" "aws-demo-private-subnet-4" {
  vpc_id            = aws_vpc.demo-vpc.id
  cidr_block        = "11.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "aws-demo-private-subnet-2"
  }
}

resource "aws_internet_gateway" "aws-demo-igw" {
  vpc_id = aws_vpc.demo-vpc.id
  tags = {
    Name = "aws-demo-igw"
  }
}

resource "aws_route_table" "aws-demo-public-rt" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws-demo-igw.id
  }

  tags = {
    Name = "aws-demo-public-rt"
  }
}

resource "aws_route_table" "aws-demo-private-rt" {
  vpc_id = aws_vpc.demo-vpc.id

  #   route {
  #     cidr_block = "11.0.1.0/24"
  #     gateway_id = "local"
  #   }

  #   depends_on = [ aws_subnet.aws-demo-public-subnet-1, aws_subnet.aws-demo-public-subnet-3 ]
  tags = {
    Name = "aws-demo-public-rt"
  }
}

resource "aws_route_table_association" "aws-demo-public-rt_a1" {
  subnet_id      = aws_subnet.aws-demo-public-subnet-1.id
  route_table_id = aws_route_table.aws-demo-public-rt.id
}

resource "aws_route_table_association" "aws-demo-public-rt_a2" {
  subnet_id      = aws_subnet.aws-demo-public-subnet-3.id
  route_table_id = aws_route_table.aws-demo-public-rt.id
}

resource "aws_route_table_association" "aws-demo-private-rt_a3" {
  subnet_id      = aws_subnet.aws-demo-private-subnet-2.id
  route_table_id = aws_route_table.aws-demo-private-rt.id
}

resource "aws_route_table_association" "aws-demo-private-rt_a4" {
  subnet_id      = aws_subnet.aws-demo-private-subnet-4.id
  route_table_id = aws_route_table.aws-demo-private-rt.id
}

resource "aws_security_group" "allow_tls" {
  name = "allow_tls"
  vpc_id = aws_vpc.demo-vpc.id
  description = "Allow TLS inbound traffic and all outbound traffic"
  tags = {
    Name = "allow_tls"
    Description = "Allow TLS inbound traffic and all outbound traffic"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  description = "Allow TLS IPv4"
  from_port = 22
  ip_protocol = "tcp"
  to_port = 22
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  description = "Allow HTTP IPv4"
  from_port = 80
  ip_protocol = "tcp"
  to_port = 80
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.allow_tls.id
  description = "Allow all traffic IPv6"
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1" # semantically equivalent to all ports
}
  

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

# Generate a new SSH key pair locally
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "aws_instance_key" {
  key_name   = var.key_name
  public_key = tls_private_key.example.public_key_openssh
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  availability_zone           = "us-east-1a"
  key_name                    = aws_key_pair.aws_instance_key.key_name
  vpc_security_group_ids      = [aws_security_group.allow_tls.id]
  subnet_id = aws_subnet.aws-demo-public-subnet-1.id
  user_data = file("linux-server-user-data.sh") 
  # if webpage doen't show up then use command "trail -3000 /var/log/cloud-init-output.log"
}
