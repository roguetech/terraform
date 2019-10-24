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
	user_data	= "#!/bin/bash\necho 'ECS_CLUSTER=elk-cluster' > /etc/ecs/ecs.config\nstart ecs\nsysctl -w vm.max_map_count=262144\ndocker plugin install   --alias cloudstor:aws   --grant-all-permissions   docker4x/cloudstor:17.06.0-ce-aws2         CLOUD_PLATFORM=AWS         AWS_REGION=eu-west-1         EFS_SUPPORTED=0         DEBUG=1\nmkdir -p /mnt/ebs/esdata\nchmod -R 777 /mnt/ebs/"
        lifecycle {
		create_before_destroy = true
	}
}

resource "aws_autoscaling_group" "ecs-elk-autoscaling" {
	name		= "ecs-elk-autoscaling"
	vpc_zone_identifier	= [aws_subnet.main-public-1.id]
# aws_subnet.main-public-2.id]
	launch_configuration	= aws_launch_configuration.ecs-elk-launchconfig.name
	min_size		= 2
	max_size		= 2
	tag {
		key		= "Name"
		value		= "ecs-ec2-container"
		propagate_at_launch = true
	}
        tag {
                key                 = "ec2discovery"
                value               = "elk"
                propagate_at_launch = true
        }
}
