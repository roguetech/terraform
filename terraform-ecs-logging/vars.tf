variable "AWS_REGION" {
	default = "eu-west-1"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-1"
}

variable "aws_account_id" {
  default = "483452016940"
}

variable "PATH_TO_PRIVATE_KEY" {
	default = "mykey"
}

variable "PATH_TO_PUBLIC_KEY" {
	default = "mykey.pub"
}

variable "ECS_INSTANCE_TYPE" {
	default = "m5.large"
}

variable "ECS_AMIS" {
	type = map(string)
	default = {
		eu-west-1 = "ami-0963349a5568210b8"
	}
}

variable "pri_1d_cidr" {
  default = "10.13.11.0/24"
}

variable "pri_1e_cidr" {
  default = "10.13.12.0/24"
}

variable "pri_1f_cidr" {
  default = "10.13.13.0/24"
}

#variable "AWS_ACCESS_KEY" {}
#variable "AWS_SECRET_KEY" {}
