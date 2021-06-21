terraform {
	backend "s3" {
		bucket = "kitman-terraform-interview-state"
		key = "terraform/patrick-roughan"
		region = "eu-west-1"
	}
}
