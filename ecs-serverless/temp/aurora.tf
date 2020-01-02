data "aws_secretsmanager_secret" "rds_password" {
  name = "timetable_serverless_rds"
}
data "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = "${data.aws_secretsmanager_secret.rds_password.id}"
}

resource "aws_rds_cluster" "tss-aurora-serverless" {
  cluster_identifier      = "tss-aurora-serverless"
  db_subnet_group_name    = "${aws_db_subnet_group.example.name}"
  engine                  = "aurora"
  engine_mode             = "serverless"
  engine_version          = "5.6.10a"
  availability_zones      = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  database_name           = "tss-aurora-serverless"
  master_username         = "admin"
  master_password         = "${data.aws_secretsmanager_secret_version.rds_password.secret_string}"
  backup_retention_period = 5
  preferred_backup_window = "22:54-23:24"
}
