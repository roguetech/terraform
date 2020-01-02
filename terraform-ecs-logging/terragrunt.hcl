#iam_role = "arn:aws:iam::713658747859:role/vsware-terraform"

remote_state {
  backend = "s3"
  config = {
    bucket         = "terraform-state-ecs-logging"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "my-lock-table"
  }
}
