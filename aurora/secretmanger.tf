resource "aws_secretsmanager_secret" "test_password2" {
  name = "test2_serverless_rds"
}

resource "aws_secretsmanager_secret_version" "test_password2" {
  secret_id = "${aws_secretsmanager_secret.test_password2.name}"
  secret_string = "${var.aurora_password}"
}
