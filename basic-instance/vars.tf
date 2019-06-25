variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
  default = "eu-west-1"
}
variable "AMIS" {
  type = "map"
  default = {
    us-east-1 = "ami-08fb5eb0e3af3d163"
    us-west-2 = "ami-0375ca3842950ade6"
    eu-west-1 = "ami-007e3c932f184b118"
  }
}
