module "vpc" {
	source = "terraform-aws-modules/vpc/aws"
	
	name = "interview-vpc"
	cidr = "10.125.0.0/16"

	azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
	private_subnets = ["10.125.1.0/24", "10.125.2.0/24", "10.125.3.0/24"]
	public_subnets = ["10.125.4.0/24", "10.125.5.0/24", "10.125.6.0/24"]

	enable_nat_gateway = true

	tags = {
		Env = "dev"
	}
}
