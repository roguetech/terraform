# Declare templates for task definitions this include pathes to container images

data "template_file" "elasticsearch-task-definition-template1" {
  template = file("templates/elasticsearch1.json.tpl")
  vars = {
    REPOSITORY_URL = replace("713658747859.dkr.ecr.eu-west-1.amazonaws.com/elk", "https://", "")
  }
}

data "template_file" "elasticsearch-task-definition-template2" {
  template = file("templates/elasticsearch2.json.tpl")
  vars = {
    REPOSITORY_URL = replace("713658747859.dkr.ecr.eu-west-1.amazonaws.com/elk", "https://", "")
  }
}

data "template_file" "elasticsearch-task-definition-template3" {
  template = file("templates/elasticsearch3.json.tpl")
  vars = {
    REPOSITORY_URL = replace("713658747859.dkr.ecr.eu-west-1.amazonaws.com/elk", "https://", "")
  }
}

# Task definitions for elasticsearch, there is three nodes with each connect to separate
# Storage locations, so as such much have seperate task definitions

resource "aws_ecs_task_definition" "elasticsearch1-task-definition" {
  family                = "elasticsearch1"
  container_definitions = data.template_file.elasticsearch-task-definition-template1.rendered

  volume {
    name = "esdata1"
    docker_volume_configuration {
      autoprovision = true
      scope = "shared"
      driver = "rexray/ebs"
      driver_opts = {
        size = "500"
        volumetype = "gp2"
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
      driver = "rexray/ebs"
      driver_opts = {
        size = "500"
        volumetype = "gp2"
      }
    }
  }
}

resource "aws_ecs_task_definition" "elasticsearch3-task-definition" {
  family                = "elasticsearch3"
  container_definitions = data.template_file.elasticsearch-task-definition-template3.rendered

  volume {
    name = "esdata3"
    docker_volume_configuration {
      autoprovision = true
      scope = "shared"
      driver = "rexray/ebs"
      driver_opts = {
        size = "500"
        volumetype = "gp2"
      }
    }
  }
}

# 1 - General Settings
resource "aws_alb" "elasticsearch-alb" {
  name            = "elasticsearch-alb"
  subnets         = ["${aws_subnet.logging-private-1.id}", "${aws_subnet.logging-private-2.id}", "${aws_subnet.logging-private-2.id}"]
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
  vpc_id          = data.terraform_remote_state.vpc.outputs.main-vpc
  health_check {
    path = "/"
    port = 9200
  }
  depends_on = [aws_alb.elasticsearch-alb]
}

# 3 - Attach instances to target groups
resource "aws_autoscaling_attachment" "elasticsearch-attachment" {
  alb_target_group_arn = aws_alb_target_group.elasticsearch-group.arn
  autoscaling_group_name = aws_autoscaling_group.ecs-elk-autoscaling.id
}

# 4 - Specify the listeners
resource "aws_alb_listener" "elasticsearch" {
  load_balancer_arn = aws_alb.elasticsearch-alb.arn
  port              = "9200"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.elasticsearch-group.arn
    type             = "forward"
  }
}

# 5 - ALB Rules
resource "aws_alb_listener_rule" "elasticsearch-rule" {
  listener_arn = aws_alb_listener.elasticsearch.arn
  priority = 100

  action {
    type = "forward"
    target_group_arn = aws_alb_target_group.elasticsearch-group.arn
  }
  condition {
    field = "path-pattern"
    values = ["/*"]
  }
}

# Internal Elasticsearch Load Balancer

resource "aws_lb" "elasticsearch-alb-internal" {
  name               = "elasticsearch-alb-internal"
  internal           = true
  load_balancer_type = "application"
  subnets            = ["${aws_subnet.logging-private-1.id}", "${aws_subnet.logging-private-2.id}", "${aws_subnet.logging-private-2.id}"]
  security_groups    = ["${aws_security_group.elasticsearch-alb-securitygroup.id}"]

  tags = {
    Environment = "elasticsearch-alb-internal"
  }
}

resource "aws_alb_target_group" "elasticsearch-group-internal" {
  name            = "elasticsearch-group-internal"
  port            = 9200
  protocol        = "HTTP"
  vpc_id          = data.terraform_remote_state.vpc.outputs.main-vpc
  health_check {
    path = "/"
    port = 9200
  }
  depends_on = [aws_lb.elasticsearch-alb-internal]
}

# 3 - Attach instances to target groups
resource "aws_autoscaling_attachment" "elasticsearch-attachment-internal" {
  alb_target_group_arn = aws_alb_target_group.elasticsearch-group-internal.arn
  autoscaling_group_name = aws_autoscaling_group.ecs-elk-autoscaling.id
}

# 4 - Specify the listeners
resource "aws_alb_listener" "elasticsearch-internal" {
  load_balancer_arn = aws_lb.elasticsearch-alb-internal.arn
  port              = "9200"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.elasticsearch-group-internal.arn
    type             = "forward"
  }
}

# 5 - ALB Rules
resource "aws_alb_listener_rule" "elasticsearch-rule-internal" {
  listener_arn = aws_alb_listener.elasticsearch-internal.arn
  priority = 100

  action {
    type = "forward"
    target_group_arn = aws_alb_target_group.elasticsearch-group-internal.arn
  }
  condition {
    field = "path-pattern"
    values = ["/*"]
  }
}

# Declare ECS services these are seperated, due to the task_definitions being separated

resource "aws_ecs_service" "elasticsearch-service1" {
  name            = "elasticsearch1"
  cluster         = aws_ecs_cluster.elk-cluster.id
  task_definition = aws_ecs_task_definition.elasticsearch1-task-definition.arn
  desired_count   = 1
  iam_role        = aws_iam_role.vsware-ecs-service-role.arn
  depends_on      = [aws_iam_policy_attachment.vsware-ecs-service-attach1]

  load_balancer {
    target_group_arn = aws_alb_target_group.elasticsearch-group.id
    container_name = "elasticsearch"
    container_port = 9200
  }
  lifecycle {
    #ignore_changes = [task_definition]
  }
}

resource "aws_ecs_service" "elasticsearch-service2" {
  name            = "elasticsearch2"
  cluster         = aws_ecs_cluster.elk-cluster.id
  task_definition = aws_ecs_task_definition.elasticsearch2-task-definition.arn
  desired_count   = 1
  iam_role        = aws_iam_role.vsware-ecs-service-role.arn
  depends_on      = [aws_iam_policy_attachment.vsware-ecs-service-attach1]

  load_balancer {
    target_group_arn = aws_alb_target_group.elasticsearch-group.id
    container_name = "elasticsearch"
    container_port = 9200
  }
  lifecycle {
    #ignore_changes = [task_definition]
  }
}

resource "aws_ecs_service" "elasticsearch-service3" {
  name            = "elasticsearch3"
  cluster         = aws_ecs_cluster.elk-cluster.id
  task_definition = aws_ecs_task_definition.elasticsearch3-task-definition.arn
  desired_count   = 1
  iam_role        = aws_iam_role.vsware-ecs-service-role.arn
  depends_on      = [aws_iam_policy_attachment.vsware-ecs-service-attach1]

  load_balancer {
    target_group_arn = aws_alb_target_group.elasticsearch-group.id
    container_name = "elasticsearch"
    container_port = 9200
  }
  lifecycle {
    #ignore_changes = [task_definition]
  }
}
