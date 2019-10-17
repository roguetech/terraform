output "elb" {
  value = aws_elb.elasticsearch-elb.dns_name
}
#output "container" {
#  value = aws_ecr_repository.elasticsearch.repository_url
#}
