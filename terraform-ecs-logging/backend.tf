data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "no-visma-inschool-preprod-terraform-state"
    key            = "inschool/terraform.tfstate"
    region         = "eu-west-1"
  }
}

terraform {
  backend "s3" {}
}
