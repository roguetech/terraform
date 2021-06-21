resource "aws_s3_bucket" "instance-bucket" {
	bucket = "kitman-labs-fhjresdas-instance-bucket"
	acl = "private"

	tags = {
		Name = "Kitman-Labs-Interview-Bucket"
		Env = "dev"
	}
}
