resource "aws_ecs_cluster" "spin-test" {
	name = "spin-test"
}

resource "aws_launch_configuration" "ecs-spin-lc" {
	name_prefix = "ecs-spin-lc"
        image_id = var.ECS_AMIS[var.AWS_REGION]
        instance_type = var.ECS_INSTANCE_TYPE
        key_name = aws_key_pair.spin-key.key_name
        iam_instance_profile = aws_iam_instance_profile.ecs-spin-role.id
        security_groups = [aws_security_group.ecs-securitygroup.id]
        user_data	= "#!/bin/bash\necho 'ECS_CLUSTER=spin-test' > /etc/ecs/ecs.config\nstart ecs"
        lifecycle {
		create_before_destroy = true
	}
}

resource "aws_autoscaling_group" "ecs-spin-asg" {
	name = "ecs-spin-asg"
	vpc_zone_identifier = [aws_subnet.main-public-1.id,aws_subnet.main-public-1.id]
        launch_configuration = aws_launch_configuration.ecs-spin-lc.name 
        min_size = 1
        max_size = 3
        tag {
             key = "Name"
             value = "ecs-spin"
             propagate_at_launch = true
        }
}

