provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source                  = "../../000-Modules/VPC"
  vpcName                 = var.vpc_name
  cidrBlock               = var.main_cidr_block
  projectCode             = var.project_code
  publicSubnetCIDRBlocks  = var.public_subnet_cidr_block
  privateSubnetCIDRBlocks = var.private_subnet_cidr_block
  availabilityZones       = data.aws_availability_zones.available.names
}

#Create Launch Template for Auto Scaling Group
module "launch_template" {
  source             = "../../000-Modules/EC2/LaunchTemplate"
  launchTemplateName = var.launch_template_name
  projectCode        = var.project_code
  instanceType       = var.instance_type
  keyName            = var.key_name
  availabilityZone   = data.aws_availability_zones.available.names[0]
  securityGroupIds   = [module.vpc.security_group_id]
  subnetId           = module.vpc.public_subnet_ids[0]
  userData           = filebase64("linux-server-user-data.sh")
  instanceName       = "Linux-Public-Server"
}

resource "aws_lb_target_group" "target_group" {
  name        = "${var.project_code}targetgroup"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  health_check {
    interval = 30
    path = "/"
    port = "traffic-port"
    protocol = "HTTP"
    timeout = 5
    healthy_threshold = 3
    unhealthy_threshold = 3
    matcher = "200-299"
  }
  tags = {
    ProjectCode = var.project_code
  }
}

resource "aws_lb" "application_load_balancer" {
  name                       = "${var.project_code}loadbalancer"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [module.vpc.security_group_id]
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
    type = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  depends_on = [ aws_lb.application_load_balancer ]
  tags = {
    ProjectCode = var.project_code
  }
}


resource "aws_autoscaling_group" "auto_scaling_group" {
  name                      = "${var.project_code}autoscalinggroup"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  health_check_grace_period = 20
  health_check_type         = "ELB"
  force_delete              = true
  vpc_zone_identifier       = module.vpc.public_subnet_ids
  availability_zones        = data.aws_availability_zones.available.names
  target_group_arns         = [aws_lb_target_group.target_group.arn]
  launch_template {
    id      = module.launch_template.launch_template_id
    version = "$Latest"
  }
  depends_on = [ aws_lb.application_load_balancer, aws_lb_listener.http_listner ]
  lifecycle {
    create_before_destroy = true
  }
}