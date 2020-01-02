remote_state {
  backend = "s3"
  config = {
    bucket         = "my-terraform-state-testing"
    key            = "aurora/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "my-lock-table"
  }
}
