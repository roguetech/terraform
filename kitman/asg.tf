resource "aws_autoscaling_group" "test-instance-asg" {
	name = "test-instance-asg"
	availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
	desired_capacity = 1
	max_size = 1
	min_size = 1

	launch_template = aws_launch_template.test-instance-lt.id
}

resource "aws_launch_template" "test-instance-lt" {
	name = "test-instance-lt"
	instance_type = "t3.micro"
	image_id = "ami-0ac43988dfd31ab9a"
	key_name = "aws_key" 
}

resource "aws_autoscaling_attachment" "test-instance" {
	autoscaling_group_name = aws_autoscaling_group.test-instance-asg.id
	alb_target_group_arn = aws_alb_target_group.test-instance-tg.arn
}
