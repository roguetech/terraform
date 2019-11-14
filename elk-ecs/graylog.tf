# app

data "template_file" "mongodb-task-definition-template" {
  template = file("templates/mongodb.json.tpl")
  vars = {
    REPOSITORY_URL = replace("483452016940.dkr.ecr.eu-west-1.amazonaws.com/mongo", "https://", "")
  }
}

#resource "aws_ecs_task_definition" "mongodb-task-definition" {
#  family                = "mongodb"
#  container_definitions = data.template_file.mongodb-task-definition-template.rendered
#}

data "template_file" "graylog-task-definition-template" {
  template = file("templates/graylog.json.tpl")
  vars = {
    REPOSITORY_URL = replace("483452016940.dkr.ecr.eu-west-1.amazonaws.com/graylog", "https://", "")
    REPOSITORY_URL1 = replace("483452016940.dkr.ecr.eu-west-1.amazonaws.com/mongo", "https://", "")
    ELASTIC_URL = aws_elb.elasticsearch-elb.dns_name
    GRAYLOG_URL = aws_alb.graylog-alb.dns_name
  }
}

resource "aws_ecs_task_definition" "graylog-task-definition" {
  family                = "graylog"
  container_definitions = data.template_file.graylog-task-definition-template.rendered
}

resource "aws_elb" "graylog-elb-filebeat" {
  name = "graylog-elb"

  listener {
    instance_port     = 5044
    instance_protocol = "tcp"
    lb_port           = 5044
    lb_protocol       = "tcp"
  }

#  listener {
#    instance_port     = 5600
#    instance_protocol = "http"
#    lb_port           = 5600
#    lb_protocol       = "http"
#  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
    target              = "TCP:5044"
    interval            = 60
  }

#  cross_zone_load_balancing   = true
#  idle_timeout                = 400
#  connection_draining         = true
#  connection_draining_timeout = 400

  subnets         = [aws_subnet.main-public-1.id]
  security_groups = [aws_security_group.elasticsearch-elb-securitygroup.id]

  tags = {
    Name = "graylog-elb-filebeat"
  }
}

# 1 - General Settings
resource "aws_alb" "graylog-alb" {
  name            = "graylog-alb"
  subnets         = ["${aws_subnet.main-public-1.id}", "${aws_subnet.main-public-2.id}"]
  security_groups = ["${aws_security_group.elasticsearch-elb-securitygroup.id}"]
  tags = {
     Name = "graylog-alb"
  }
}

# Network load balancer

resource "aws_lb" "graylog-filebeat" {
  name                              = "graylog-filebeat" #can also be obtained from the variable nlb_config
  load_balancer_type                = "network"
  subnets         = ["${aws_subnet.main-public-1.id}", "${aws_subnet.main-public-2.id}"]
  #security_groups = ["${aws_security_group.elasticsearch-elb-securitygroup.id}"]
  tags = {
     Name = "graylog-alb"
  }
}

#resource "aws_alb" "graylog-alb1" {
#  name            = "graylog-alb1"
#  subnets         = ["${aws_subnet.main-public-1.id}", "${aws_subnet.main-public-2.id}"]
#  security_groups = ["${aws_security_group.elasticsearch-elb-securitygroup.id}"]
#  tags = {
#     Name = "graylog-alb1"
#  }
#}

# 2 - Create Target Group
resource "aws_alb_target_group" "graylog-web-group" {
  name            = "graylog-web-group"
  port            = 9000
  protocol        = "HTTP"
  vpc_id          = "${aws_vpc.main.id}"
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
  vpc_id                  = "${aws_vpc.main.id}"
  health_check {
    interval            = 30
    port                = 5044
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  depends_on = ["aws_lb.graylog-filebeat"]
  tags = {
    Environment = "test"
  }
}


#resource "aws_alb_target_group" "graylog-filebeat-group" {
#  name            = "graylog-filebeat-group"
#  port            = 5044
#  protocol        = "HTTP"
#  vpc_id          = "${aws_vpc.main.id}"
#  health_check {
#    path = "/api"
#    port = 9000
#  }
#  depends_on = ["aws_alb.graylog-alb1"]
#}

# 3 - Attach instances to target groups
resource "aws_autoscaling_attachment" "graylog-web-attachment" {
  alb_target_group_arn = "${aws_alb_target_group.graylog-web-group.arn}"
  autoscaling_group_name = "${aws_autoscaling_group.ecs-elk-autoscaling.id}"
  #target_id = "$aws_instance.example-instance.id}"
  #port = 9000
}

#resource "aws_autoscaling_attachment" "graylog-filebeat-attachment" {
#  lb_target_group_arn = "${aws_lb_target_group.graylog-filebeat-group.arn}"
#  autoscaling_group_name = "${aws_autoscaling_group.ecs-elk-autoscaling.id}"
#  #port = 5044
#}

# 4 - Specify the listeners
resource "aws_alb_listener" "graylog-web" {
  load_balancer_arn = "${aws_alb.graylog-alb.arn}"
  port              = "9000"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.graylog-web-group.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "graylog-filebeat" {
  load_balancer_arn   = aws_lb.graylog-filebeat.arn
  port                = "5044"
  protocol            = "TCP"
  default_action {
     target_group_arn = "${aws_lb_target_group.graylog-filebeat-group.arn}"
     type             = "forward"
  }
}

#resource "aws_alb_listener" "graylog-filebeat" {
#  load_balancer_arn = "${aws_alb.graylog-alb1.arn}"
#  port              = "5044"
#  protocol          = "HTTP"
#
#  default_action {
#    target_group_arn = "${aws_alb_target_group.graylog-filebeat-group.arn}"
#    type             = "forward"
#  }
#}

# 5 - ALB Rules
resource "aws_alb_listener_rule" "graylog-web-rule" {
  listener_arn = "${aws_alb_listener.graylog-web.arn}"
  priority = 100

  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.graylog-web-group.arn}"
  }
  condition {
    field = "path-pattern"
    values = ["/*"]
  }
}

#resource "aws_alb_listener_rule" "graylog-filebeat-rule" {
#  listener_arn = "${aws_alb_listener.graylog-filebeat.arn}"
#  priority = 100
#
#  action {
#    type = "forward"
#    target_group_arn = "${aws_alb_target_group.graylog-filebeat-group.arn}"
#  }
#  condition {
#    field = "path-pattern"
#    values = ["/*"]
#  }
#}

resource "aws_ecs_service" "graylog-service" {
  name            = "graylog"
  cluster         = aws_ecs_cluster.elk-cluster.id
  task_definition = aws_ecs_task_definition.graylog-task-definition.arn
  desired_count   = 1
  #iam_role        = aws_iam_role.ecs-service-role.arn
  depends_on      = [aws_iam_policy_attachment.ecs-service-attach1]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.graylog-web-group.id}"
    container_name = "graylog"
    container_port = 9000
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.graylog-filebeat-group.id}"
    container_name = "graylog"
    container_port = 5044
  }

  lifecycle {
    #ignore_changes = [task_definition]
  }
}
