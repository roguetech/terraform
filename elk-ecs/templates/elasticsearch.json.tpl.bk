[
  {
    "essential": true,
    "memory": 2048,
    "name": "elasticsearch",
    "cpu": 512,
    "image": "${REPOSITORY_URL}:1",
    "environment": [
        {
          "name": "cluster.name",
          "value": "docker-cluster"
        },
        {
          "name": "bootstrap.memory_lock",
          "value": "true"
        },
        {
          "name": "ES_JAVA_OPTS",
          "value": "-Xms512m -Xmx512m"
        },
        {
          "name": "discovery.type",
          "value": "single-node"
        }
      ],
    "ulimit": [
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
