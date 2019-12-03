[
  {
    "essential": true,
    "memory": 4096,
    "name": "TimetableSchedularTask",
    "cpu": 1024,
    "image": "${REPOSITORY_URL}:1",
    "containerName": "timetable-solver-mock",
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
          "name": "SCHEDULER_STATUS_ITEM_IDE",
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
