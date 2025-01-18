resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id =  var.securityGroupId
  description       = "Allow HTTP IPv4"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

variable "securityGroupId" {
  type = string
}