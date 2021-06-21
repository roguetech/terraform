resource "aws_security_group" "alb-test-instance" {
	name = "alb-test-instance"
	description = "allow http traffic to test instance"
	vpc_id = aws_vpc.vpc.id

	ingress {
		description = "allow port 80 http traffic"
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = [aws_vpc.vpc.cidr_block]
	}

	egress {
		description = "allow all outgoing traffic"
		from_port = 0
		to_port = 0 
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"] 

	}

	tags = {
		Name = "allow http traffic"
	}
}
