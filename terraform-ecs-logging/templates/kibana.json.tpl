[
  {
    "essential": true,
    "memory": 1024,
    "name": "kibana",
    "cpu": 128,
    "image": "${REPOSITORY_URL}:1",
    "containerName": "kibana",
    "environment": [
        {
          "name": "ELASTICSEARCH_HOSTS",
          "value": "http://${elastic_url}:9200"
        },
        {
          "name": "SERVER_HOST",
          "value": "0.0.0.0"
        }
    ],
    "portMappings": [
        {
            "containerPort": 5601,
            "hostPort": 5601
        }
    ]
  }
]
