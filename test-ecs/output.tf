output "elb" {
  value = aws_alb.graylog-alb.dns_name
}

#output "kibana-elb" {
#  value = aws_elb.kibana-elb.dns_name
#}
#output "container" {
#  value = aws_ecr_repository.elasticsearch.repository_url
#}
