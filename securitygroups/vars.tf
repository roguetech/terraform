variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
  default = "eu-west-1"
}

variable "AMIS" {
  type = "map"
  default = {
    us-east-1 = "ami-0cfee17793b08a293"
    us-west-2 = "ami-09eb5e8a83c7aa890"
    eu-west-1 = "ami-03746875d916becc0"
  }
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "mykey1"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "mykey1.pub"
}

variable "INSTANCE_USERNAME" {
  default = "ubuntu"
}
