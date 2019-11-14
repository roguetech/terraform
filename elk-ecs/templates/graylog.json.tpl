[
  {
    "essential": true,
    "memory": 512,
    "name": "mongo",
    "cpu": 128,
    "image": "${REPOSITORY_URL1}:1",
    "containerName": "mongo",
    "alias": "mongo"
  },
  {
    "essential": true,
    "memory": 512,
    "name": "graylog",
    "cpu": 128,
    "image": "${REPOSITORY_URL}:1",
    "containerName": "graylog",
    "links": ["mongo:mongo"],
    "environment": [
        {
          "name": "GRAYLOG_PASSWORD_SECRET",
          "value": "forpasswordencryption"
        },
        {
          "name": "GRAYLOG_ROOT_PASSWORD_SHA2",
          "value": "8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918"
        },
        {
          "name": "GRAYLOG_HTTP_BIND_ADDRESS",
          "value": "0.0.0.0:9000"
        },
        {
          "name": "GRAYLOG_HTTP_EXTERNAL_URI",
          "value": "http://${GRAYLOG_URL}:9000/"
        },
        {
          "name": "GRAYLOG_ELASTICSEARCH_HOSTS",
          "value": "http://${ELASTIC_URL}:9200"
        },
        {
          "name": "GRAYLOG_ELASTICSEARCH_ENV_HTTP.HOST",
          "value": "${ELASTIC_URL}"
        },
        {
          "name": "GRAYLOG_ELASTICSEARCH_PORT_9200_TCP_PORT",
          "value": "9200"
        }
    ],
    "portMappings": [
        {
            "containerPort": 5044,
            "hostPort": 5044
        },
        {
            "containerPort": 9000,
            "hostPort": 9000
        },
        {
            "containerPort": 1514,
            "hostPort": 1514
        },
        {
            "containerPort": 12201,
            "hostPort": 12201
        }
    ]
  }
]
