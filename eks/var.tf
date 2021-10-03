variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
  default = "eu-west-1"
}
variable "AWS_ACCOUNT_ID" { 
	default = "483452016940"
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::483452016940:user/patrick"
      username = "patrick"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::483452016940:user/roguetech"
      username = "roguetech"
      groups   = ["system:masters"]
    },
  ]
}
