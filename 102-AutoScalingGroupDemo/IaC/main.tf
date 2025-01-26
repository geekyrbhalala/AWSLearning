provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source                  = "../../000-Modules/VPC"
  vpcName                 = var.vpc_name
  cidrBlock               = var.main_cidr_block
  projectCode             = var.project_code
  publicSubnetCIDRBlocks  = var.public_subnet_cidr_block
  privateSubnetCIDRBlocks = var.private_subnet_cidr_block
  availabilityZones       = ["us-east-1a", "us-east-1b"]
}

resource "aws_security_group" "elb_http_traffic" {
  name        = "${var.project_code}-elb_tls_http_traffic"
  description = "Allow tls,http traffic for web server"
  vpc_id      = module.vpc.vpc_id

  # Ingress rules: Allow HTTP and SSH traffic
  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rules: Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # "-1" means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    ProjectCode = var.project_code
  }
}

resource "aws_security_group" "ec2_ssh_http_traffics" {
  name        = "${var.project_code}-all_tls_http_traffic"
  description = "Allow tls,http traffic for web server"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rules: Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # "-1" means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    ProjectCode = var.project_code
  }
}

resource "aws_security_group_rule" "allow_http_from_elb_sg" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ec2_ssh_http_traffics.id
  source_security_group_id = aws_security_group.elb_http_traffic.id
}

module "launch_template" {
  source                   = "../../000-Modules/EC2/LaunchTemplate"
  launchTemplateName       = var.launch_template_name
  projectCode              = var.project_code
  instanceType             = var.instance_type
  keyName                  = var.key_name
  associatePublicIPAddress = true
  availabilityZone         = module.vpc.az_and_subnet.az
  securityGroupIds         = [aws_security_group.ec2_ssh_http_traffics.id]
  subnetId                 = module.vpc.az_and_subnet.subnet
  userData                 = filebase64("linux-server-user-data.sh")
  instanceName             = "Linux-Public-Server"

  depends_on = [aws_security_group.ec2_ssh_http_traffics]
}

resource "aws_lb_target_group" "target_group" {
  name        = "${var.project_code}targetgroup"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  health_check {
    interval            = 60
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 50
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }
  tags = {
    ProjectCode = var.project_code
  }
}

resource "aws_lb" "application_load_balancer" {
  name                       = "${var.project_code}loadbalancer"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.elb_http_traffic.id]
  subnets                    = module.vpc.public_subnet_ids
  enable_deletion_protection = false
  idle_timeout               = 60
  enable_http2               = true
  tags = {
    ProjectCode = var.project_code
  }
}

resource "aws_lb_listener" "http_listner" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  depends_on = [aws_lb.application_load_balancer]
  tags = {
    ProjectCode = var.project_code
  }
}

resource "aws_autoscaling_group" "auto_scaling_group" {
  name                      = "${var.project_code}autoscalinggroup"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  health_check_grace_period = 120
  health_check_type         = "ELB"
  force_delete              = true
  vpc_zone_identifier       = module.vpc.public_subnet_ids
  target_group_arns         = [aws_lb_target_group.target_group.arn]
  launch_template {
    id      = module.launch_template.launch_template_id
    version = "$Latest"
  }
  depends_on = [aws_lb.application_load_balancer, aws_lb_listener.http_listner]
  lifecycle {
    create_before_destroy = true
  }
}

output "elb-endpoint" {
  value = aws_lb.application_load_balancer.dns_name
}