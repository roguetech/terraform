"Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "ecs:CreateCluster",
            "ecs:DeregisterContianerInstance",
            "ecs:DiscoverPollEndPoint",
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
            "logs:PutLogEvents"
        ],
        "Resource": "*"
    }
]
