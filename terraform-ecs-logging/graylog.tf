# app

#data "template_file" "mongodb-task-definition-template" {
#  template = file("templates/mongodb.json.tpl")
#  vars = {
#    REPOSITORY_URL = replace("713658747859.dkr.ecr.eu-west-1.amazonaws.com/mongo", "https://", "")
#  }
#}

data "template_file" "graylog-task-definition-template" {
  template = file("templates/graylog.json.tpl")
  vars = {
    REPOSITORY_URL = replace("483452016940.dkr.ecr.eu-west-1.amazonaws.com/graylog", "https://", "")
    REPOSITORY_URL1 = replace("483452016940.dkr.ecr.eu-west-1.amazonaws.com/mongo", "https://", "")
    ELASTIC_URL = aws_lb.elasticsearch-alb-internal.dns_name
    GRAYLOG_URL = aws_alb.graylog-web-alb.dns_name
  }
}

resource "aws_ecs_task_definition" "graylog-task-definition" {
  family                = "graylog"
  container_definitions = data.template_file.graylog-task-definition-template.rendered

  volume {
    name = "mongodb"
    docker_volume_configuration {
      autoprovision = true
      scope = "shared"
      driver = "rexray/ebs"
      driver_opts = {
        size = "10"
        volumetype = "gp2"
      }
    }
  }
}

#resource "aws_ecs_task_definition" "mongodb-task-definition" {
#  family                = "graylog"
#  container_definitions = data.template_file.mongodb-task-definition-template.rendered
#
#  volume {
#    name = "mongodb"
#    docker_volume_configuration {
#      autoprovision = true
#      scope = "shared"
#      driver = "rexray/ebs"
#      driver_opts = {
#        size = "5"
#        volumetype = "gp2"
#      }
#    }
#  }
#}

# 1 - General Settings
resource "aws_alb" "graylog-web-alb" {
  name            = "graylog-web-alb"
  subnets         = ["${aws_subnet.logging-private-1.id}", "${aws_subnet.logging-private-2.id}", "${aws_subnet.logging-private-3.id}"]
  security_groups = ["${aws_security_group.graylog-alb-securitygroup.id}"]
  tags = {
     Name = "graylog-web-alb"
  }
}

# Internal load_balancer
resource "aws_alb" "graylog-web-alb-internal" {
  name            = "graylog-web-alb-internal"
  internal        = true
  subnets         = ["${aws_subnet.logging-private-1.id}", "${aws_subnet.logging-private-2.id}", "${aws_subnet.logging-private-3.id}"]
  security_groups = ["${aws_security_group.graylog-alb-securitygroup.id}"]
  tags = {
     Name = "graylog-web-alb"
  }
}

# Network load balancer

resource "aws_lb" "graylog-filebeat" {
  name                              = "graylog-filebeat" #can also be obtained from the variable nlb_config
  internal                          = true
  load_balancer_type                = "network"
  subnets         = ["${aws_subnet.logging-private-1.id}", "${aws_subnet.logging-private-2.id}", "${aws_subnet.logging-private-3.id}"]
  #security_groups = ["${aws_security_group.graylog-alb-securitygroup.id}"]
  tags = {
     Name = "graylog-alb"
  }
}

# 2 - Create Target Group
resource "aws_alb_target_group" "graylog-web-group" {
  name            = "graylog-web-group"
  port            = 9000
  protocol        = "HTTP"
  vpc_id          = aws_vpc.main.id
  health_check {
    path = "/api"
    port = 9000
  }
}

resource "aws_alb_target_group" "graylog-web-group-internal" {
  name            = "graylog-web-group-internal"
  port            = 9000
  protocol        = "HTTP"
  vpc_id          = aws_vpc.main.id
  health_check {
    path = "/api"
    port = 9000
  }
}

# Target group network lb

resource "aws_lb_target_group" "graylog-filebeat-group" {
  name                  = "graylog-filebeat-group"
  port                  = 5044
  protocol              = "TCP"
  vpc_id                = aws_vpc.main.id
  health_check {
    interval            = 30
    port                = 5044
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  depends_on = [aws_lb.graylog-filebeat]
  tags = {
    Environment = "Production"
  }
}


# 3 - Attach instances to target groups
resource "aws_autoscaling_attachment" "graylog-web-attachment" {
  alb_target_group_arn = aws_alb_target_group.graylog-web-group.arn
  autoscaling_group_name = aws_autoscaling_group.ecs-elk-autoscaling.id
}

resource "aws_autoscaling_attachment" "graylog-web-attachment-internal" {
  alb_target_group_arn = aws_alb_target_group.graylog-web-group-internal.arn
  autoscaling_group_name = aws_autoscaling_group.ecs-elk-autoscaling.id
}

# 4 - Specify the listeners

# Redirect from port 80 to port 9000
resource "aws_alb_listener" "graylog-web-80" {
  load_balancer_arn = aws_alb.graylog-web-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"

    redirect {
      port        = "9000"
      protocol    = "HTTP"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "graylog-web" {
  load_balancer_arn = aws_alb.graylog-web-alb.arn
  port              = "9000"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.graylog-web-group.arn
    type             = "forward"
  }
}

resource "aws_alb_listener" "graylog-web-internal" {
  load_balancer_arn = aws_alb.graylog-web-alb-internal.arn
  port              = "9000"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.graylog-web-group-internal.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "graylog-filebeat" {
  load_balancer_arn   = aws_lb.graylog-filebeat.arn
  port                = "5044"
  protocol            = "TCP"
  default_action {
     target_group_arn = aws_lb_target_group.graylog-filebeat-group.arn
     type             = "forward"
  }
}

# 5 - ALB Rules
resource "aws_alb_listener_rule" "graylog-web-rule" {
  listener_arn = aws_alb_listener.graylog-web.arn
  priority = 100

  action {
    type = "forward"
    target_group_arn = aws_alb_target_group.graylog-web-group.arn
  }
  condition {
    field = "path-pattern"
    values = ["/*"]
  }
}

resource "aws_alb_listener_rule" "graylog-web-rule-internal" {
  listener_arn = aws_alb_listener.graylog-web-internal.arn
  priority = 100

  action {
    type = "forward"
    target_group_arn = aws_alb_target_group.graylog-web-group-internal.arn
  }
  condition {
    field = "path-pattern"
    values = ["/*"]
  }
}

resource "aws_ecs_service" "graylog-service" {
  name            = "graylog"
  cluster         = aws_ecs_cluster.elk-cluster.id
  task_definition = aws_ecs_task_definition.graylog-task-definition.arn
  desired_count   = 1
  #iam_role        = aws_iam_role.ecs-service-role.arn
  depends_on      = [aws_iam_policy_attachment.ecs-service-attach1]

  load_balancer {
    target_group_arn = aws_alb_target_group.graylog-web-group.id
    container_name = "graylog"
    container_port = 9000
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.graylog-filebeat-group.id
    container_name = "graylog"
    container_port = 5044
  }

  lifecycle {
    #ignore_changes = [task_definition]
  }
}
