data "aws_eks_cluster" "cluster" {
  name = module.mgmt-test-pr.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.mgmt-test-pr.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "mgmt-test-pr" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "mgmt-test-pr"
  cluster_version = "1.17"
  subnets         = ["subnet-09f733c3da495702d", "subnet-09e287e1f8db52cbf", "subnet-0162a0246ad359299"]
  vpc_id          = "vpc-0db2cb4db038328b0"

  worker_groups = [
    {
      instance_type = "m4.large"
      asg_max_size  = 2
    }
  ]

  map_users    = var.map_users
}
