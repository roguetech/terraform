# Creates Template file for timetable solver

data "template_file" "timetable-solver-definition-template" {
  template = file("templates/timetable-solver.json.tpl")
  vars = {
    REPOSITORY_URL = replace("713658747859.dkr.ecr.eu-west-1.amazonaws.com/timetable-solver-worker", "https://", "")
  }
}

# Creating ECS task definitions setting up to use FARGATE

resource "aws_ecs_task_definition" "timetable-solver-task-definition" {
  family                    = "timetable-solver"
  requires_compatibilities  = ["FARGATE"]
  network_mode              = "awsvpc"
  cpu                       = 1024
  memory                    = 4096
  execution_role_arn        = aws_iam_role.start-timetable-solver-task-iam-role.arn
  task_role_arn             = aws_iam_role.start-timetable-solver-task-iam-role.arn
  container_definitions     = data.template_file.timetable-solver-definition-template.rendered
}
