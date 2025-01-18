resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = var.securityGroupId
  description       = "Allow all traffic IPv6"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

variable "securityGroupId" {
  type = string
}