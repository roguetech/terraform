[
  {
    "essential": true,
    "memory": 2048,
    "name": "elasticsearch2",
    "cpu": 512,
    "image": "${REPOSITORY_URL}:1",
    "containerName": "elasticsearch2",
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
          "name": "discovery.zen.ping.unicast.hosts",
          "value": "elasticsearch"
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
