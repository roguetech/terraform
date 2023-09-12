module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    name = "scaling-test-vpc"
    cidr = "10.0.0.0/16"

    azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

    enable_nat_gateway = true
    single_nat_gateway = true

    tags = {
        Terraform = "true"
        Environment = "scaling-test"
    }
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name = "scaling-test-cluster"
  cluster_version = "1.27"

  cluster_endpoint_public_access = true

  vpc_id = module.vpc.vpc_id

  subnet_ids = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  manage_aws_auth_configmap = true
  create_aws_auth_configmap = true 

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::559347283443:user/engineers/patrick-admin"
      username = "patrick-admin"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_roles = [
    # We need to add in the Karpenter node IAM role for nodes launched by Karpenter
    {
      rolearn  = module.karpenter.role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    },
  ]

  cluster_addons = {
    coredns = {
      most_recent = true
      configuration_values = jsonencode({
        computeType = "Fargate"
        # Ensure that we fully utilize the minimum amount of resources that are supplied by
        # Fargate https://docs.aws.amazon.com/eks/latest/userguide/fargate-pod-configuration.html
        # Fargate adds 256 MB to each pod's memory reservation for the required Kubernetes
        # components (kubelet, kube-proxy, and containerd). Fargate rounds up to the following
        # compute configuration that most closely matches the sum of vCPU and memory requests in
        # order to ensure pods always have the resources that they need to run.
        resources = {
          limits = {
            cpu = "0.25"
            # We are targeting the smallest Task size of 512Mb, so we subtract 256Mb from the
            # request/limit to ensure we can fit within that task
            memory = "256M"
          }
          requests = {
            cpu = "0.25"
            # We are targeting the smallest Task size of 512Mb, so we subtract 256Mb from the
            # request/limit to ensure we can fit within that task
            memory = "256M"
          }
        }
      })
    }
    #kube_proxy = {}
    
    vpc-cni = {
      most_recent = true
    }

  }

  create_cluster_security_group = false
  create_node_security_group    = false

  fargate_profiles = {
    karpenter = {
      selectors = [
        { namespace = "karpenter" }
      ]
    }
    kube-system = {
      selectors = [
        { namespace = "kube-system" }
      ]
    }
  
    }
 }

 module "karpenter" {
    source = "terraform-aws-modules/eks/aws//modules/karpenter"

    cluster_name = module.eks.cluster_name

    irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
    irsa_namespace_service_accounts = ["karpenter:karpenter"]

    policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }

    tags = {
      Environment = "dev"
      Terraform   = "true"
    }
 }

