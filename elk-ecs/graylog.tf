# app

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
  }
}

resource "aws_ecs_task_definition" "graylog-task-definition" {
  family                = "graylog"
  container_definitions = data.template_file.graylog-task-definition-template.rendered
}

#resource "aws_elb" "graylog-elb" {
#  name = "graylog-elb"
#
#  listener {
#    instance_port     = 9000
#    instance_protocol = "http"
#    lb_port           = 9000
#    lb_protocol       = "http"
#  }

#  listener {
#    instance_port     = 5600
#    instance_protocol = "http"
#    lb_port           = 5600
#    lb_protocol       = "http"
#  }

#  health_check {
#    healthy_threshold   = 3
#    unhealthy_threshold = 3
#    timeout             = 10
#    target              = "HTTP:9000/"
#    interval            = 60
#  }

#  cross_zone_load_balancing   = true
#  idle_timeout                = 400
#  connection_draining         = true
#  connection_draining_timeout = 400

#  subnets         = [aws_subnet.main-public-1.id]
#  security_groups = [aws_security_group.elasticsearch-elb-securitygroup.id]

#  tags = {
#    Name = "graylog-elb"
#  }
#}

# 1 - General Settings
resource "aws_alb" "graylog-alb" {
  name            = "graylog-alb"
  subnets         = ["${aws_subnet.main-public-1.id}", "${aws_subnet.main-public-2.id}"]
  security_groups = ["${aws_security_group.elasticsearch-elb-securitygroup.id}"]
  tags = {
     Name = "graylog-alb"
  }
}

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

resource "aws_alb_target_group" "graylog-filebeat-group" {
  name            = "graylog-filebeat-group"
  port            = 5044
  protocol        = "HTTP"
  vpc_id          = "${aws_vpc.main.id}"
  health_check {
    path = "/api"
    port = 9000
  }
}

# 3 - Attach instances to target groups
resource "aws_autoscaling_attachment" "graylog-web-attachment" {
  alb_target_group_arn = "${aws_alb_target_group.graylog-web-group.arn}"
  autoscaling_group_name = "${aws_autoscaling_group.ecs-elk-autoscaling.id}"
  #target_id = "$aws_instance.example-instance.id}"
  #port = 9000
}

resource "aws_autoscaling_attachment" "graylog-filebeat-attachment" {
  alb_target_group_arn = "${aws_alb_target_group.graylog-filebeat-group.arn}"
  autoscaling_group_name = "${aws_autoscaling_group.ecs-elk-autoscaling.id}"
}

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

resource "aws_alb_listener" "graylog-filebeat" {
  load_balancer_arn = "${aws_alb.graylog-alb.arn}"
  port              = "5044"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.graylog-filebeat-group.arn}"
    type             = "forward"
  }
}

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

resource "aws_alb_listener_rule" "graylog-filebeat-rule" {
  listener_arn = "${aws_alb_listener.graylog-filebeat.arn}"
  priority = 100

  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.graylog-filebeat-group.arn}"
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
    target_group_arn = "${aws_alb_target_group.graylog-web-group.id}"
    container_name = "graylog"
    container_port = 9000
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.graylog-filebeat-group.id}"
    container_name = "graylog"
    container_port = 5044
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}
