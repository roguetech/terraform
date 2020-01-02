data "template_file" "mongodb-task-definition-template" {
  template = file("templates/mongodb.json.tpl")
  vars = {
    REPOSITORY_URL = replace("483452016940.dkr.ecr.eu-west-1.amazonaws.com/mongodb", "https://", "")
  }
}

resource "aws_ecs_task_definition" "mongodb-task-definition" {
  family                = "mongo"
  container_definitions = data.template_file.mongodb-task-definition-template.rendered

  volume {
    name = "mongodb"
    docker_volume_configuration {
      autoprovision = true
      scope = "shared"
      driver = "rexray/ebs"
      driver_opts = {
        size = "5"
        volumetype = "gp2"
      }
    }
  }
}

resource "aws_ecs_service" "mongodb-service" {
  name            = "mongodb"
  cluster         = aws_ecs_cluster.elk-cluster.id
  task_definition = aws_ecs_task_definition.mongodb-task-definition.arn
  desired_count   = 1
  #iam_role        = aws_iam_role.ecs-service-role.arn

  lifecycle {
    #ignore_changes = [task_definition]
  }
}
