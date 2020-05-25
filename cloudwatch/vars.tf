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

variable "name_prefix" {
  description = "Name to be prefixed to all resources"
  default     = "tools"
  type        = string
}

variable "name_format" {
  description = "Naming scheme as a string, to use with the format() function."
  default     = "%s-auto-recover-%02d"
  type        = string
}

variable "ec2_instance_ids" {
  description = "EC2 instance ids of VMs that should receive auto-recover capabilities."
  default     = ["i-08c0231b743a395b7"]
  type        = list(string)
}

variable "maximum_failure_duration" {
  description = "Maximum amount of system status checks failures period in seconds before recovery kicks in."
  default     = "60"
  type        = string
}

variable "alarm_actions" {
  description = "list of alarm actions to append to the default (optional)"
  default     = []
  type        = list(string)
}
