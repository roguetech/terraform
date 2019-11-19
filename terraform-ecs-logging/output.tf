output "elb" {
  value = aws_alb.elasticsearch-alb.dns_name
}
output "kibana-elb" {
  value = aws_elb.kibana-elb.dns_name
}

output "graylog_filebeat" {
  value = aws_lb.graylog-filebeat.dns_name
}
