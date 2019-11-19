# app

data "template_file" "elasticsearch-task-definition-template1" {
  template = file("templates/elasticsearch1.json.tpl")
  vars = {
    REPOSITORY_URL = replace("483452016940.dkr.ecr.eu-west-1.amazonaws.com/elk", "https://", "")
  }
}

data "template_file" "elasticsearch-task-definition-template2" {
  template = file("templates/elasticsearch2.json.tpl")
  vars = {
    REPOSITORY_URL = replace("483452016940.dkr.ecr.eu-west-1.amazonaws.com/elk", "https://", "")
  }
}

resource "aws_ecs_task_definition" "elasticsearch1-task-definition" {
  family                = "elasticsearch1"
  container_definitions = data.template_file.elasticsearch-task-definition-template1.rendered

  volume {
    name = "esdata1"
    docker_volume_configuration {
      autoprovision = true
      scope = "shared"
      driver = "cloudstor:aws"
      driver_opts = {
        size = "11"
        volumetype = "gp2"
        backing = "relocatable"
      }
    }
  } 
}

resource "aws_ecs_task_definition" "elasticsearch2-task-definition" {
  family                = "elasticsearch2"
  container_definitions = data.template_file.elasticsearch-task-definition-template2.rendered

  volume {
    name = "esdata2"
    docker_volume_configuration {
      autoprovision = true
      scope = "shared"
      driver = "cloudstor:aws"
      driver_opts = {
        size = "11"
        volumetype = "gp2"
        backing = "relocatable"
      }
    }
  }
}

#resource "aws_elb" "elasticsearch-elb" {
#  name = "elasticsearch-elb"
#
#  listener {
#    instance_port     = 9200
#    instance_protocol = "http"
#    lb_port           = 9200
#    lb_protocol       = "http"
#  }

#  health_check {
#    healthy_threshold   = 3
#    unhealthy_threshold = 3
#    timeout             = 30
#    target              = "HTTP:9200/"
#    interval            = 60
#  }

#  cross_zone_load_balancing   = true
#  idle_timeout                = 400
#  connection_draining         = true
#  connection_draining_timeout = 400

#  subnets         = [aws_subnet.main-public-1.id] 
#aws_subnet.main-public-2.id]
#  security_groups = [aws_security_group.elasticsearch-elb-securitygroup.id]

#  tags = {
#    Name = "elasticsearch-elb"
#  }
#}

# 1 - General Settings
resource "aws_alb" "elasticsearch-alb" {
  name            = "elasticsearch-alb"
  subnets         = ["${aws_subnet.main-public-1.id}", "${aws_subnet.main-public-2.id}"]
  security_groups = ["${aws_security_group.elasticsearch-alb-securitygroup.id}"]
  tags = {
     Name = "elasticsearch-alb"
  }
}

# 2 - Create Target Group
resource "aws_alb_target_group" "elasticsearch-group" {
  name            = "elasticsearch-group"
  port            = 9200
  protocol        = "HTTP"
  vpc_id          = "${aws_vpc.main.id}"
  health_check {
    path = "/"
    port = 9200
  }
}

# 3 - Attach instances to target groups
resource "aws_autoscaling_attachment" "elasticsearch-attachment" {
  alb_target_group_arn = "${aws_alb_target_group.elasticsearch-group.arn}"
  autoscaling_group_name = "${aws_autoscaling_group.ecs-elk-autoscaling.id}"
}

# 4 - Specify the listeners
resource "aws_alb_listener" "elasticsearch" {
  load_balancer_arn = "${aws_alb.elasticsearch-alb.arn}"
  port              = "9200"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.elasticsearch-group.arn}"
    type             = "forward"
  }
}

# 5 - ALB Rules
resource "aws_alb_listener_rule" "elasticsearch-rule" {
  listener_arn = "${aws_alb_listener.elasticsearch.arn}"
  priority = 100

  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.elasticsearch-group.arn}"
  }
  condition {
    field = "path-pattern"
    values = ["/*"]
  }
}

resource "aws_ecs_service" "elasticsearch-service1" {
  name            = "elasticsearch1"
  cluster         = aws_ecs_cluster.elk-cluster.id
  task_definition = aws_ecs_task_definition.elasticsearch1-task-definition.arn 
  desired_count   = 1
  iam_role        = aws_iam_role.ecs-service-role.arn
  depends_on      = [aws_iam_policy_attachment.ecs-service-attach1]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.elasticsearch-group.id}"
    container_name = "elasticsearch"
    container_port = 9200
  }

#  load_balancer {
#    elb_name       = aws_elb.elasticsearch-elb.name
#    container_name = "elasticsearch"
#    container_port = 9200
#  }
  lifecycle {
    #ignore_changes = [task_definition]
  }
}

resource "aws_ecs_service" "elasticsearch-service2" {
  name            = "elasticsearch2"
  cluster         = aws_ecs_cluster.elk-cluster.id
  task_definition = aws_ecs_task_definition.elasticsearch2-task-definition.arn
  desired_count   = 1
  iam_role        = aws_iam_role.ecs-service-role.arn
  depends_on      = [aws_iam_policy_attachment.ecs-service-attach1]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.elasticsearch-group.id}"
    container_name = "elasticsearch"
    container_port = 9200
  }

#  load_balancer {
#    elb_name       = aws_elb.elasticsearch-elb.name
#    container_name = "elasticsearch"
#    container_port = 9200
#  }
  lifecycle {
    ignore_changes = [task_definition]
  }
}
