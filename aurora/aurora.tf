resource "aws_rds_cluster" "test-aurora-serverless" {
  cluster_identifier      = "test-aurora-serverless"
  db_subnet_group_name    = "${aws_db_subnet_group.example.name}"
  engine                  = "aurora"
  engine_mode             = "serverless"
  engine_version          = "5.6.10a"
  availability_zones      = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  database_name           = "test-aurora-serverless"
  master_username         = "admin"
  master_password         = "${data.aws_secretsmanager_secret_version.test_password.secret_string}"
  backup_retention_period = 5
  preferred_backup_window = "22:54-23:24"
}
