data "aws_secretsmanager_secret" "test_password" {
  name = "test_serverless_rds"
}

data "aws_secretsmanager_secret_version" "test_password" {
  secret_id = "${data.aws_secretsmanager_secret.test_password.id}"
}

