resource "aws_secretsmanager_secret" "test_password" {
  name = "test_serverless_rds"
}

resource "aws_secretsmanager_secret_version" "test_password" {
  secret_id = "${aws_secretsmanager_secret.test_password.name}"
  secret_string = ""
}

