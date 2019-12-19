resource "aws_security_group" "ecs-securitygroup" {
  vpc_id      = data.terraform_remote_state.vpc.outputs.main-vpc
  name        = "ecs"
  description = "security group for ecs"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    security_groups = [aws_security_group.graylog-alb-securitygroup.id]
  }

  ingress {
    from_port       = 9200
    to_port         = 9200
    protocol        = "tcp"
    security_groups = [aws_security_group.elasticsearch-alb-securitygroup.id]
  }

  ingress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    security_groups = [aws_security_group.graylog-alb-securitygroup.id]
    cidr_blocks = ["10.13.0.0/16"]
    #cidr_blocks = ["80.233.43.227/32", "213.233.132.148/32", "10.224.60.24/32", "10.209.107.227/32", "31.187.0.23/32", "89.100.110.85/32","89.100.110.81/32","52.212.198.51/32","195.150.192.250/32", "213.94.231.245/32", "83.71.159.224/32", "54.171.12.38/32","63.34.245.21/32"]
  }

  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    security_groups = [aws_security_group.kibana-alb-securitygroup.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #security_groups = [data.terraform_remote_state.vpc.outputs.security-group-ireland-office]
    cidr_blocks = ["80.233.43.227/32", "213.233.132.148/32", "10.224.60.24/32", "10.209.107.227/32", "31.187.0.23/32", "89.100.110.85/32","89.100.110.81/32","52.212.198.51/32","195.150.192.250/32", "213.94.231.245/32", "83.71.159.224/32", "54.171.12.38/32","63.34.245.21/32"]
  }
  tags = {
    Name = "ecs-securitygroup"
  }
}

resource "aws_security_group" "elasticsearch-alb-securitygroup" {
  vpc_id      = data.terraform_remote_state.vpc.outputs.main-vpc
  name        = "elasticsearch-alb"
  description = "security group for ecs"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    #security_groups = [data.terraform_remote_state.vpc.outputs.security-group-ireland-office]
    cidr_blocks = [var.pri_1d_cidr, var.pri_1e_cidr, var.pri_1f_cidr, "10.13.0.0/16", "80.233.43.227/32", "213.233.132.148/32", "10.224.60.24/32", "10.209.107.227/32", "31.187.0.23/32", "89.100.110.85/32","89.100.110.81/32","52.212.198.51/32","195.150.192.250/32", "213.94.231.245/32", "83.71.159.224/32", "54.171.12.38/32","63.34.245.21/32"]
  }

  tags = {
    Name = "elasticsearch-alb"
  }
}

resource "aws_security_group" "kibana-alb-securitygroup" {
  vpc_id      = data.terraform_remote_state.vpc.outputs.main-vpc
  name        = "kibana-alb"
  description = "security group for kibana ecs"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  #security_groups = [data.terraform_remote_state.vpc.outputs.security-group-ireland-office]
  cidr_blocks =  [var.pri_1d_cidr, var.pri_1e_cidr, var.pri_1f_cidr, "80.233.43.227/32", "213.233.132.148/32", "10.224.60.24/32", "10.209.107.227/32", "31.187.0.23/32", "89.100.110.85/32","89.100.110.81/32","52.212.198.51/32","195.150.192.250/32", "213.94.231.245/32", "83.71.159.224/32", "54.171.12.38/32","63.34.245.21/32"]
}

  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    #security_groups = [data.terraform_remote_state.vpc.outputs.security-group-ireland-office]
    cidr_blocks =  [var.pri_1d_cidr, var.pri_1e_cidr, var.pri_1f_cidr, "10.13.0.0/16", "80.233.43.227/32", "213.233.132.148/32", "10.224.60.24/32", "10.209.107.227/32", "31.187.0.23/32", "89.100.110.85/32","89.100.110.81/32","52.212.198.51/32","195.150.192.250/32", "213.94.231.245/32", "83.71.159.224/32", "54.171.12.38/32","63.34.245.21/32"]
  }

  tags = {
    Name = "kibana-alb"
  }
}

resource "aws_security_group" "graylog-alb-securitygroup" {
  vpc_id      = data.terraform_remote_state.vpc.outputs.main-vpc
  name        = "graylog-ecs-alb"
  description = "security group for graylog ecs"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    #security_groups = [data.terraform_remote_state.vpc.outputs.security-group-ireland-office]
    cidr_blocks = [var.pri_1d_cidr, var.pri_1e_cidr, var.pri_1f_cidr, "10.13.0.0/16", "80.233.43.227/32", "213.233.132.148/32", "10.224.60.24/32", "10.209.107.227/32", "31.187.0.23/32", "89.100.110.85/32","89.100.110.81/32","52.212.198.51/32","195.150.192.250/32", "213.94.231.245/32", "83.71.159.224/32", "54.171.12.38/32","63.34.245.21/32"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    #security_groups = [data.terraform_remote_state.vpc.outputs.security-group-ireland-office]
    cidr_blocks = [var.pri_1d_cidr, var.pri_1e_cidr, var.pri_1f_cidr, "10.13.0.0/16", "80.233.43.227/32", "213.233.132.148/32", "10.224.60.24/32", "10.209.107.227/32", "31.187.0.23/32", "89.100.110.85/32","89.100.110.81/32","52.212.198.51/32","195.150.192.250/32", "213.94.231.245/32", "83.71.159.224/32", "54.171.12.38/32","63.34.245.21/32"]
  }

  ingress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    #security_groups = [data.terraform_remote_state.vpc.outputs.security-group-ireland-office]
    cidr_blocks = [var.pri_1d_cidr, var.pri_1e_cidr, var.pri_1f_cidr, "10.13.0.0/16", "80.233.43.227/32", "213.233.132.148/32", "10.224.60.24/32", "10.209.107.227/32", "31.187.0.23/32", "89.100.110.85/32","89.100.110.81/32","52.212.198.51/32","195.150.192.250/32", "213.94.231.245/32", "83.71.159.224/32", "54.171.12.38/32","63.34.245.21/32"]
  }

  tags = {
    Name = "graylog-ecs-alb"
  }
}

resource "aws_security_group" "elasticsearch-node-communication" {
  vpc_id     = data.terraform_remote_state.vpc.outputs.main-vpc
  name       = "elasticsearch-node-comms"
  description = "security group so nodes can form a cluster"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9300
    to_port     = 9300
    protocol    = "tcp"
    cidr_blocks = [var.pri_1d_cidr, var.pri_1e_cidr, var.pri_1f_cidr]
  }

  ingress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = [var.pri_1d_cidr, var.pri_1e_cidr, var.pri_1f_cidr]
  }

  ingress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "udp"
    cidr_blocks = [var.pri_1d_cidr, var.pri_1e_cidr, var.pri_1f_cidr]
  }

  tags = {
    Name = "elasticsearch-node-comms"
  }
}
