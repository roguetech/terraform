# Kibana task definition templates including container image location

data "template_file" "kibana-task-definition-template" {
  template = file("templates/kibana.json.tpl")
  vars = {
    REPOSITORY_URL = replace("713658747859.dkr.ecr.eu-west-1.amazonaws.com/kibana", "https://", "")
    elastic_url = aws_lb.elasticsearch-alb-internal.dns_name
  }
}

# Declare task definition for kibana

resource "aws_ecs_task_definition" "kibana-task-definition" {
  family                = "kibana"
  container_definitions = data.template_file.kibana-task-definition-template.rendered
}

# 1 - General Settings
resource "aws_alb" "kibana-alb" {
  name            = "kibana-alb"
  subnets         = ["${aws_subnet.logging-private-1.id}", "${aws_subnet.logging-private-2.id}", "${aws_subnet.logging-private-2.id}"]
  security_groups = ["${aws_security_group.kibana-alb-securitygroup.id}"]
  tags = {
     Name = "kibana-alb"
  }
}

# 2 - Create Target Group
resource "aws_alb_target_group" "kibana-group" {
  name            = "kibana-group"
  port            = 5601
  protocol        = "HTTP"
  vpc_id          = data.terraform_remote_state.vpc.outputs.main-vpc
  health_check {
    path = "/app/kibana"
    port = 5601
  }
  depends_on = [aws_alb.kibana-alb]
}

# 3 - Attach instances to target groups
resource "aws_autoscaling_attachment" "kibana-attachment" {
  alb_target_group_arn = aws_alb_target_group.kibana-group.arn
  autoscaling_group_name = aws_autoscaling_group.ecs-elk-autoscaling.id
}

# 4 - Specify the listeners

# Redirect from port 80 to port 5601
resource "aws_alb_listener" "kibana-80" {
  load_balancer_arn = aws_alb.kibana-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"

    redirect {
      port        = "5601"
      protocol    = "HTTP"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "kibana" {
  load_balancer_arn = aws_alb.kibana-alb.arn
  port              = "5601"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.kibana-group.arn
    type             = "forward"
  }
}

# 5 - ALB Rules
resource "aws_alb_listener_rule" "kibana-rule" {
  listener_arn = aws_alb_listener.kibana.arn
  priority = 100

  action {
    type = "forward"
    target_group_arn = aws_alb_target_group.kibana-group.arn
  }
  condition {
    field = "path-pattern"
    values = ["/*"]
  }
}

# Internal Kibana Load Balancer

resource "aws_lb" "kibana-alb-internal" {
  name               = "kibana-alb-internal"
  internal           = true
  load_balancer_type = "application"
  subnets            = ["${aws_subnet.logging-private-1.id}", "${aws_subnet.logging-private-2.id}", "${aws_subnet.logging-private-2.id}"]
  security_groups    = ["${aws_security_group.kibana-alb-securitygroup.id}"]

  tags = {
    Environment = "kibana-alb-internal"
  }
}

# Internal Kibana Load Balancer Group

resource "aws_alb_target_group" "kibana-group-internal" {
  name            = "kibana-group-internal"
  port            = 5601
  protocol        = "HTTP"
  vpc_id          = data.terraform_remote_state.vpc.outputs.main-vpc
  health_check {
    path = "/app/kibana"
    port = 5601
  }
  depends_on = [aws_lb.kibana-alb-internal]
}

# 3 - Attach instances to target groups
resource "aws_autoscaling_attachment" "kibana-attachment-internal" {
  alb_target_group_arn = aws_alb_target_group.kibana-group-internal.arn
  autoscaling_group_name = aws_autoscaling_group.ecs-elk-autoscaling.id
}

# 4 - Specify the listeners
resource "aws_alb_listener" "kibana-internal" {
  load_balancer_arn = aws_lb.kibana-alb-internal.arn
  port              = "5601"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.kibana-group-internal.arn
    type             = "forward"
  }
}

# 5 - ALB Rules
resource "aws_alb_listener_rule" "kibana-rule-internal" {
  listener_arn = aws_alb_listener.kibana-internal.arn
  priority = 100

  action {
    type = "forward"
    target_group_arn = aws_alb_target_group.kibana-group-internal.arn
  }
  condition {
    field = "path-pattern"
    values = ["/*"]
  }
}

resource "aws_ecs_service" "kibana-service" {
  name            = "kibana"
  cluster         = aws_ecs_cluster.elk-cluster.id
  task_definition = aws_ecs_task_definition.kibana-task-definition.arn
  desired_count   = 1
  #iam_role        = aws_iam_role.ecs-service-role.arn
  #depends_on      = [aws_iam_policy_attachment.ecs-service-attach1]

#  load_balancer {
#    elb_name       = aws_alb.kibana-alb.name
#    container_name = "kibana"
#    container_port = 5601
#  }
  load_balancer {
    target_group_arn = aws_alb_target_group.kibana-group.id
    container_name = "kibana"
    container_port = 5601
  }
  lifecycle {
    #ignore_changes = [task_definition]
  }
  depends_on = [aws_alb.kibana-alb]
}
