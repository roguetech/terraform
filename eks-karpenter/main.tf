module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    name = "scaling-test-vpc"
    cidr = "10.0.0.0/16"

    azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

    enable_nat_gateway = true

    tags = {
        Terraform = "true"
        Environment = "scaling-test"
    }
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name = "scaling-test-cluster"
  cluster_version = "1.27"

  vpc_id = module.vpc.name

  subnets = module.vpc.public_subnets

  cluster_addons = {
    coredns = {
      preserve = true
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    kube_proxy = {
      most_recent = true
      }
    vpc-cni = {
      most_recent = true
      }
    }

    depends_on = [
        aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
    ]
 }

