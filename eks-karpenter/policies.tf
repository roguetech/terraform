/* resource "aws_iam_role" "cluster" {
  name = "scaling-test-cluster-role"

  assume_role_policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "eks.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  POLICY
}

resource "aws_iam_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  name       = "scaling-test-cluster-AmazonEKSClusterPolicy"
  roles      = [aws_iam_role.cluster.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
  
resource "aws_security_group" "eks-cluster-sg" {
    name = "eks-cluster-sg"
    description = "EKS cluster security group"

    vpc_id = module.vpc.vpc_id
    tags = {
      Name = "eks-cluster-sg"
    }
}

resource "aws_security_group_rule" "ingress" {
    description = "Allow all inbound traffic from nodes and control plane"
    from_port = 443
    protocol = "tcp"
    security_group_id = aws_security_group.eks-cluster-sg.id
    source_security_group_id = aws.security_group.eks-nodes.id
    to_port = 443
    type = "ingress"
}

resource "aws_security_group_rule" "egress" {
  description = "Allow all outbound traffic to nodes and control plane"
  from_port = 1024
  protocol = "tcp"
  security_group_id = aws_iam_policy_attachment.cluster_AmazonEKSClusterPolicy
} */