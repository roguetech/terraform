terraform {
 backend "s3" {
  bucket = "s3-terraform-spin-ecs"
  key = "state/"
  region = "eu-west-1"
 }
}
