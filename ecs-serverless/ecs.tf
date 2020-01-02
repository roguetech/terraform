# Create ECS Cluster
resource "aws_ecs_cluster" "timetable-solver-cluster" {
  name = "timetable-solver-cluster"
}
