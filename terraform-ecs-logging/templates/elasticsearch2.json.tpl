[
  {
    "essential": true,
    "memory": 4096,
    "name": "elasticsearch",
    "cpu": 512,
    "image": "${REPOSITORY_URL}:5",
    "containerName": "elasticsearch",
    "mountPoints": [
        {
          "sourceVolume": "esdata2",
          "containerPath": "/opt/elasticsearch/data"
        }
    ],
    "environment": [
        {
          "name": "ES_JAVA_OPTS",
          "value": "-Xms2048m -Xmx2048m"
        },
        {
          "name": "LimitMEMLOCK",
          "value": "infinity"
        }
      ],
    "ulimits": [
        {
          "softLimit": -1,
          "hardLimit": -1,
          "name": "memlock"
        },
        {
          "softLimit": 65535,
          "hardLimit": 65535,
          "name": "nofile"
        }
   ],
    "portMappings": [
        {
            "containerPort": 9200,
            "hostPort": 9200
        },
	      {
	          "containerPort": 9300,
            "hostPort": 9300
	      }
    ]
  }
]
