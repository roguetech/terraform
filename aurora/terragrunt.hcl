terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "aurora/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "my-lock-table"
  }
}
