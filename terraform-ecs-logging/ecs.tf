#Cluster
resource "aws_ecs_cluster" "elk-cluster" {
	name = "elk-cluster"
}

resource "aws_launch_configuration" "ecs-elk-launchconfig" {
	name_prefix	= "ecs-launchconfig"
	image_id	= var.ECS_AMIS[var.AWS_REGION]
	instance_type	= var.ECS_INSTANCE_TYPE
	key_name	= aws_key_pair.mykeypair.key_name
	iam_instance_profile	= aws_iam_instance_profile.ecs-ec2-role.id
	security_groups	= [aws_security_group.ecs-securitygroup.id, aws_security_group.elasticsearch-node-communication.id]
	user_data	= "#!/bin/bash\necho 'ECS_CLUSTER=elk-cluster' > /etc/ecs/ecs.config\nstart ecs\nsysctl -w vm.max_map_count=262144\ndocker plugin install rexray/ebs REXRAY_PREEMPT=true EBS_REGION=eu-west-1 --grant-all-permissions\nchown -R elasticsearch:elasticsearch /opt/elasticsearch/data"
        lifecycle {
		create_before_destroy = true
	}
}

resource "aws_autoscaling_group" "ecs-elk-autoscaling" {
	name		= "ecs-elk-autoscaling"
	vpc_zone_identifier	= [aws_subnet.logging-private-1.id]
		#aws_subnet.logging-private-2.id, aws_subnet.logging-private-3.id]
	launch_configuration	= aws_launch_configuration.ecs-elk-launchconfig.name
	min_size		= 3
	max_size		= 3
	tag {
		key		              = "Name"
		value		            = "ecs-ec2-container"
		propagate_at_launch = true
	}
  tag {
    key                 = "ec2discovery"
    value               = "elk"
    propagate_at_launch = true
  }
}
