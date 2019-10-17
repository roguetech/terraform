output "elb" {
  value = aws_elb.myapp-elb.dns_name
}
output "container" {
  value = aws_ecr_repository.myapp.repository_url
}
