data "template_file" "myapp-task-definition-template" {
    template    = file("template/myapp.json.tpl")
    vars = {
        REPOSITORY_URL = replace("483452016940.dkr.ecr.eu-west-1.amazonaws.com/elk", "https://", "")
    }
}

resource "aws_ecs_task_definition" "myapp-task-definition" {
    family      = "myapp"
    container_definitions = data.template_file.myapp-task-definition-template.rendered
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

resource "aws_alb" "graylog-alb1" {
  name            = "graylog-alb1"
  subnets         = ["${aws_subnet.main-public-1.id}", "${aws_subnet.main-public-2.id}"]
  security_groups = ["${aws_security_group.elasticsearch-elb-securitygroup.id}"]
  tags = {
     Name = "graylog-alb1"
  }
}

# 2 - Create Target Group
resource "aws_alb_target_group" "graylog-web-group" {
  name            = "graylog-web-group"
  port            = 9200
  protocol        = "HTTP"
  vpc_id          = "${aws_vpc.main.id}"
  health_check {
    path = "/"
    port = 9200
  }
}

resource "aws_alb_target_group" "graylog-filebeat-group" {
  name            = "graylog-filebeat-group"
  port            = 9300
  protocol        = "HTTP"
  vpc_id          = "${aws_vpc.main.id}"
  health_check {
    path = "/"
    port = 9300
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
  #port = 5044
}

# 4 - Specify the listeners
resource "aws_alb_listener" "graylog-web" {
  load_balancer_arn = "${aws_alb.graylog-alb.arn}"
  port              = "9200"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.graylog-web-group.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "graylog-filebeat" {
  load_balancer_arn = "${aws_alb.graylog-alb1.arn}"
  port              = "9300"
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

resource "aws_ecs_service" "myapp-service" {
    name = "myapp"
    cluster = "${aws_ecs_cluster.test-cluster.id}"
    task_definition = "${aws_ecs_task_definition.myapp-task-definition.arn}"
    desired_count = 1
    iam_role = "${aws_iam_role.ecs-service-role.arn}"
    depends_on = ["aws_iam_policy_attachment.ecs-service-attach1"]

    load_balancer {
       target_group_arn = "${aws_alb_target_group.graylog-web-group.id}"
       container_name = "myapp"
       container_port = 9200
    }

    load_balancer {
       target_group_arn = "${aws_alb_target_group.graylog-filebeat-group.id}"
       container_name = "myapp"
       container_port = 9300
    }

    #lifecycle { ignore_changes = ["task_definition"] }
}
