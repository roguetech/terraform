[
  {
    "essential": true,
    "memory": 4096,
    "name": "timetable-solver-worker",
    "cpu": 1024,
    "image": "${REPOSITORY_URL}:latest",
    "containerName": "timetable-solver-worker",
    "environment": [
        {
          "name": "AWS_BUCKET_NAME",
          "value": ""
        },
        {
          "name": "DEVELOPMENT_MODE",
          "value": "true"
        },
        {
          "name": "SCHEDULER_PAYLOAD_S3_ID",
          "value": ""
        },
        {
          "name": "AWS_REGION",
          "value": ""
        },
        {
          "name": "SCHEDULER_JOB_NAME",
          "value": ""
        },
        {
          "name": "RDS_RESOURCE_ARN",
          "value": ""
        },
        {
          "name": "RDS_SECRET_ARN",
          "value": ""
        },
        {
          "name": "RDS_DATABASE_NAME",
          "value": ""
        }
      ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/TimetableSchedulerTask",
        "awslogs-region": "eu-west-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
