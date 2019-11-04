# app

#data "template_file" "mongodb-task-definition-template" {
#  template = file("templates/mongodb.json.tpl")
#  vars = {
#    REPOSITORY_URL = replace("483452016940.dkr.ecr.eu-west-1.amazonaws.com/mongodb", "https://", "")
#  }
#}

#resource "aws_ecs_task_definition" "mongodb-task-definition" {
#  family                = "mongodb"
#  container_definitions = data.template_file.mongodb-task-definition-template.rendered
#}

#resource "aws_ecs_service" "mongodb-service" {
#  name            = "mongodb"
#  cluster         = aws_ecs_cluster.elk-cluster.id
#  task_definition = aws_ecs_task_definition.mongodb-task-definition.arn 
#  desired_count   = 1
#  #iam_role        = aws_iam_role.ecs-service-role.arn
#  depends_on      = [aws_iam_policy_attachment.ecs-service-attach1]

#  lifecycle {
#    ignore_changes = [task_definition]
#  }
#}
