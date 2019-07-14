terraform {
  backend "s3" {
    bucket = "terraform-state-hfg65"
    key = "terraform/backend"
  }
}
