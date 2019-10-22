variable "AWS_REGION" {
	default = "eu-west-1"
}

variable "PATH_TO_PRIVATE_KEY" {
	default = "mykey"
}

variable "PATH_TO_PUBLIC_KEY" {
	default = "mykey.pub"
}

variable "ECS_INSTANCE_TYPE" {
	default = "t2.medium"
}

variable "ECS_AMIS" {
	type = map(string)
	default = {
		eu-west-1 = "ami-0963349a5568210b8"
	}
}

variable "ebs_block_device" {
  default     = "/dev/xvdcz"
  description = "EBS block devices to attach to the instance. (default: /dev/xvdcz)"
}

variable "docker_storage_size" {
  default     = "22"
  description = "EBS Volume size in Gib that the ECS Instance uses for Docker images and metadata "
}

variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
