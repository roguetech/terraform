resource "aws_rds_cluster" "tss-aurora-serverless" {
  cluster_identifier      = "tss-aurora-serverless"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.03.2"
  availability_zones      = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  database_name           = "tss-aurora-serverless"
  master_username         = "admin"
  master_password         = ""
  backup_retention_period = 5
  preferred_backup_window = "22:54-23:24"
}
