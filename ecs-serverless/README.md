Introduction

This terraform code creates infrastruture to enable serverless to start and run timetable solver serverless.
This includes creating api gateway, ECS Cluster with fargate task definition. S3 Buckets. And all the IAM
Roles around the services.

severless.com is used to deploy lambdas and update api gateway
So, for Terraform: IAM roles, ECS Cluster, S3, Aurora serverless should be provisioned
The solution diagram: https://confluence.visma.com/display/VSWAR/Solution
The services for solver are listed in the description

Issues

Changes
