# app

data "template_file" "kibana-task-definition-template" {
  template = file("templates/kibana.json.tpl")
  vars = {
    REPOSITORY_URL = replace("483452016940.dkr.ecr.eu-west-1.amazonaws.com/kibana", "https://", "")
    elastic_url = aws_elb.elasticsearch-elb.dns_name
  }
}

resource "aws_ecs_task_definition" "kibana-task-definition" {
  family                = "kibana"
  container_definitions = data.template_file.kibana-task-definition-template.rendered
}

resource "aws_elb" "kibana-elb" {
  name = "kibana-elb"

  listener {
    instance_port     = 5601
    instance_protocol = "http"
    lb_port           = 5601
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
    target              = "HTTP:5601/app/kibana"
    interval            = 60
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  subnets         = [aws_subnet.main-public-1.id]
  security_groups = [aws_security_group.elasticsearch-elb-securitygroup.id]

  tags = {
    Name = "kibana-elb"
  }
}

resource "aws_ecs_service" "kibana-service" {
  name            = "kibana"
  cluster         = aws_ecs_cluster.elk-cluster.id
  task_definition = aws_ecs_task_definition.kibana-task-definition.arn 
  desired_count   = 1
  #iam_role        = aws_iam_role.ecs-service-role.arn
  #depends_on      = [aws_iam_policy_attachment.ecs-service-attach1]

  load_balancer {
    elb_name       = aws_elb.kibana-elb.name
    container_name = "kibana"
    container_port = 5601
  }
  lifecycle {
    #ignore_changes = [task_definition]
  }
  depends_on = [aws_elb.kibana-elb]
}
