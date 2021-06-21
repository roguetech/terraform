resource "aws_iam_role" "instance_s3_access" {
	name = "instance_s3_access"
}

resource "aws_iam_policy" "instance_s3_access_policy" {
	name = "instance_s3_access_policy"
	path = "/"
	description = "allow instance to read and write to s3 bucket"

	policy = <<POLICY
	{
		"Version": "2012-10-17",
		"Statement": [
			{
				"Effect":"Allow",
				"Action": [
					"s3:GetObject"
					"s3:PutObject"
				],
				"Resource": aws_s3.instance-bucket.id
			}
		]
	}
	POLICY
}

resource "aws_iam_policy_attachment" "instance_s3_access" {
	name = "instance_s3_access"
	policy = aws_iam_policy.instance_s3_access_policy.arn
	roles = aws_iam_role.instance_s3_access.name
}


