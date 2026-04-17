locals {
    node_grp_policies = [
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
        "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    ]
}

resource "aws_iam_role" "eks-cluster-role" {
    name = "eks-cluster-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_policy_attachment" "eks-cluster-policy" {
    name = "eks-cluster-policy"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    roles = [aws_iam_role.eks-cluster-role.name]
}

resource "aws_iam_role" "eks_node_group_role" {
    name = "eks-node-group-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "eks_node_grp_policy_attachment" {
    for_each = toset(local.node_grp_policies)
    role = aws_iam_role.eks_node_group_role.name
    policy_arn = each.value
}