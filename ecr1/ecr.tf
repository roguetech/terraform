resource "aws_ecr_repository" "test-elk" {
  name = "test-elk"
}

resource "aws_ecr_repository" "test-kibana" {
  name = "test-kibana"
}

resource "aws_ecr_repository" "test-mongo" {
  name = "test-mongo"
}

resource "aws_ecr_repository" "test-graylog" {
  name = "test-graylog"
}
