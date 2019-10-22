# app

data "template_file" "elasticsearch-task-definition-template" {
  template = file("templates/elasticsearch.json.tpl")
  vars = {
    REPOSITORY_URL = replace(aws_ecr_repository.elk.repository_url, "https://", "")
  }
}

#resource "aws_efs_file_system" "es-data" {
#  creation_token = "es-persistent-data"
#  performance_mode = "generalPurpose"

#  tags {
#    Name = "elasticsearch-data"
#  }
#}

#resource "aws_efs_mount_target" "elasticsearch" {
#  file_system_id = "${aws_efs_file_system.es-data.id}"
#  subnet_id      = "${aws_subnet.main-public-1.id}"
#}

resource "aws_ecs_task_definition" "elasticsearch-task-definition" {
  family                = "elasticsearch"
  container_definitions = data.template_file.elasticsearch-task-definition-template.rendered

  volume {
    name = "esdata"
    docker_volume_configuration {
      autoprovision = true
      scope = "shared"
      driver = "cloudstor:aws"
      driver_opts = {
        size = "10"
        volumetype = "gp2"
        backing = "relocatable"
      }
    #host_path = "/mnt/ebs/esdata"
    }
  } 
}

resource "aws_elb" "elasticsearch-elb" {
  name = "elasticsearch-elb"

  listener {
    instance_port     = 9200
    instance_protocol = "http"
    lb_port           = 9200
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 30
    target              = "HTTP:9200/"
    interval            = 60
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  subnets         = [aws_subnet.main-public-1.id] 
#aws_subnet.main-public-2.id]
  security_groups = [aws_security_group.elasticsearch-elb-securitygroup.id]

  tags = {
    Name = "elasticsearch-elb"
  }
}

resource "aws_ecs_service" "elasticsearch-service" {
  name            = "elasticsearch"
  cluster         = aws_ecs_cluster.elk-cluster.id
  task_definition = aws_ecs_task_definition.elasticsearch-task-definition.arn
  desired_count   = 2
  iam_role        = aws_iam_role.ecs-service-role.arn
  depends_on      = [aws_iam_policy_attachment.ecs-service-attach1]

  load_balancer {
    elb_name       = aws_elb.elasticsearch-elb.name
    container_name = "elasticsearch"
    container_port = 9200
  }
  lifecycle {
    ignore_changes = [task_definition]
  }
}
