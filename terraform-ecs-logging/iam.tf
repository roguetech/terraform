resource "aws_iam_role" "vsware-ecs-ec2-role" {
  name               = "vsware-ecs-ec2-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_instance_profile" "vsware-ecs-ec2-role" {
  name = "vsware-ecs-ec2-role"
  role = aws_iam_role.vsware-ecs-ec2-role.name
}

resource "aws_iam_role_policy" "vsware-ecs-ec2-role-policy" {
name   = "vsware-ecs-ec2-role-policy"
role   = aws_iam_role.vsware-ecs-ec2-role.id
policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "ecs:CreateCluster",
              "ecs:DeregisterContainerInstance",
              "ecs:DiscoverPollEndpoint",
              "ecs:Poll",
              "ecs:RegisterContainerInstance",
              "ecs:StartTelemetrySession",
              "ecs:Submit*",
              "ecs:StartTask",
              "ecr:GetAuthorizationToken",
              "ecr:BatchCheckLayerAvailability",
              "ecr:GetDownloadUrlForLayer",
              "ecr:BatchGetImage",
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "ec2:DescribeInstances",
              "ec2:AttachVolume",
              "ec2:DetachVolume",
              "ec2:CreateVolume",
              "ec2:DeleteVolume",
              "ec2:DescribeVolumes",
              "ec2:DescribeVolumeStatus",
              "ec2:CreateSnapshot",
              "ec2:DeleteSnapshot",
              "ec2:DescribeSnapshots",
              "ecs:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        }
    ]
}
EOF

}

# ecs service role
resource "aws_iam_role" "vsware-ecs-service-role" {
name = "vsware-ecs-service-role"
assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_policy_attachment" "vsware-ecs-service-attach1" {
  name       = "vsware-ecs-service-attach1"
  roles      = [aws_iam_role.vsware-ecs-service-role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}
