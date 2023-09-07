terraform {
  backend "s3" {
    profile = "syseng"
    bucket = "terraform-bucket-calypsoai-scaling-test"
    key = "terraform.tfstate"
    dynamodb_table = "terraform-state-lock-dynamodb-01"
    region = "eu-west-1"
  }
}
