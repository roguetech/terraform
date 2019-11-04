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
    REPOSITORY_URL1 = replace("483452016940.dkr.ecr.eu-west-1.amazonaws.com/mongodb", "https://", "")
  }
}

resource "aws_ecs_task_definition" "graylog-task-definition" {
  family                = "graylog"
  container_definitions = data.template_file.graylog-task-definition-template.rendered 
}

resource "aws_elb" "graylog-elb" {
  name = "graylog-elb"

  listener {
    instance_port     = 9000
    instance_protocol = "http"
    lb_port           = 9000
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
    target              = "HTTP:9000/"
    interval            = 60
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  subnets         = [aws_subnet.main-public-1.id]
  security_groups = [aws_security_group.elasticsearch-elb-securitygroup.id]

  tags = {
    Name = "graylog-elb"
  }
}

resource "aws_ecs_service" "graylog-service" {
  name            = "graylog"
  cluster         = aws_ecs_cluster.elk-cluster.id
  task_definition = aws_ecs_task_definition.graylog-task-definition.arn 
  desired_count   = 1
  iam_role        = aws_iam_role.ecs-service-role.arn
  depends_on      = [aws_iam_policy_attachment.ecs-service-attach1]

  load_balancer {
    elb_name       = aws_elb.graylog-elb.name
    container_name = "graylog"
    container_port = 9000
  }
  lifecycle {
    ignore_changes = [task_definition]
  }
}
