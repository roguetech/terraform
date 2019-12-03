data "template_file" "timetable-solver-definition-template" {
  template = file("templates/timetable-solver.json.tpl")
  vars = {
    REPOSITORY_URL = replace("483452016940.dkr.ecr.eu-west-1.amazonaws.com/timetable-solver", "https://", "")
  }
}

resource "aws_ecs_task_definition" "timetable-solver-task-definition" {
  family                = "timetable-solver"
  container_definitions = data.template_file.timetable-solver-definition-template.rendered
}
