resource "aws_alb" "test-instance" {
	name = "test_instance-alb"
	internal = false
	load_balancer = "application"
	security_groups = [aws_security_group.alb-test-instance.id]
	subnets = aws_subnet.public_subnets.*.id
	
	enable_deletion_protection = true

	access_logs {
		bucket = aws_s3_bucket.instance-bucket.bucket
		prefix = "alb-logs"
		enabled = true
	}

	tags = {
		Env = "dev"
	}
}

resource "aws_lb_target_group" "test-instance-tg" {
	name = "test-instance-tg"
	port = 80
	protocol = "HTTP"
	target_type = "ip"
	vpc_id = aws_vpc_vpc.id
}

resource "aws_lb_listener" "test-instance-lister" {
	load_balancer_arn = aws_alb.test-instance.arn
	port = 80
	protocol = "HTTP"

	default_action {
		type = "forward"
		target_group_arn = aws_lb_target_group.test-instance-tg.arn
	}
}


