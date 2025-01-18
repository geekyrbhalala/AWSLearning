resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = var.securityGroupId
  description       = "Allow TLS IPv4"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
}

variable "securityGroupId" {
  type = string
}