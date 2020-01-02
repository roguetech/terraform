# Create Elastic Container Registory for Docker container
resource "aws_ecr_repository" "timetable-solver" {
  name = "timetable-solver-worker"
}
