output "elb" {
  value = aws_alb.elasticsearch-alb.dns_name
}

output "kibana-alb" {
  value = aws_alb.kibana-alb.dns_name
}

output "graylog-filebeat" {
  value = aws_lb.graylog-filebeat.dns_name
}

output "graylog-alb" {
  value = aws_alb.graylog-web-alb.dns_name
}

output "elk-repository-URL" {
	value = aws_ecr_repository.elk.repository_url
}

output "kibana-repository-URL" {
	value = aws_ecr_repository.elk.repository_url
}

output "graylog-repository-URL" {
	value = aws_ecr_repository.elk.repository_url
}

output "mongo-repository-URL" {
	value = aws_ecr_repository.elk.repository_url
}
