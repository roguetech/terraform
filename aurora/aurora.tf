resource "aws_db_subnet_group" "example" {
  name       = "main"
  subnet_ids = ["subnet-0e47a0e4d1e2d4971", "subnet-040fe1aa4611cda26", "subnet-0791142940e6b446f"]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_rds_cluster" "test-aurora-serverless" {
  cluster_identifier      = "test-aurora-serverless"
  db_subnet_group_name    = "${aws_db_subnet_group.example.name}"
  engine                  = "aurora"
  engine_mode             = "serverless"
  engine_version          = "5.6.10a"
  availability_zones      = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  database_name           = "testauroraserverless"
  master_username         = "admin"
  master_password         = "${aws_secretsmanager_secret_version.test_password.secret_string}"
  backup_retention_period = 5
  preferred_backup_window = "22:54-23:24"
  skip_final_snapshot       = true
}
