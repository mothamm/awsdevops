resource "aws_vpc" "eks-vpc"{
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "eks-vpc"
        }
}

resource "aws_subnet" "eks-public-subnet-1"{
    vpc_id = aws_vpc.eks-vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
      "Name" = "eks-public-subnet-1"
    }
}

resource "aws_subnet" "eks-public-subnet-2"{
    vpc_id = aws_vpc.eks-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true
    tags = {
      "Name" = "eks-public-subnet-2"
    }
}

resource "aws_subnet" "eks-private-subnet-1"{
    vpc_id = aws_vpc.eks-vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1c"
    map_public_ip_on_launch = false
    tags = {
      "Name" = "eks-private-subnet-1"
    }
}

resource "aws_subnet" "eks-private-subnet-2"{
    vpc_id = aws_vpc.eks-vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1d"
    map_public_ip_on_launch = false
    tags = {
      "Name" = "eks-private-subnet-2"
    }

}

resource "aws_internet_gateway" "eks-igw"{
    vpc_id = aws_vpc.eks-vpc.id
    tags = {
        Name = "eks-igw"
    }
}

resource "aws_route_table" "eks-rt"{
    vpc_id = aws_vpc.eks-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.eks-igw.id
    }
    tags = {
        Name = "eks-rt"
    }
}

resource "aws_route_table_association" "eks-public-subnet-1-association"{
    subnet_id = aws_subnet.eks-public-subnet-1.id
    route_table_id = aws_route_table.eks-rt.id
}

resource "aws_route_table_association" "eks-public-subnet-2-association"{
    subnet_id = aws_subnet.eks-public-subnet-2.id
    route_table_id = aws_route_table.eks-rt.id
}

resource "aws_route_table_association" "eks-private-subnet-1-association"{
    subnet_id = aws_subnet.eks-private-subnet-1.id
    route_table_id = aws_route_table.eks-rt.id
}

resource "aws_route_table_association" "eks-private-subnet-2-association"{
    subnet_id = aws_subnet.eks-private-subnet-2.id
    route_table_id = aws_route_table.eks-rt.id
}

resource "aws_security_group" "eks-sg" {
    name = "eks-sg"
    description = "Security group for EKS cluster"
    vpc_id = aws_vpc.eks-vpc.id
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }
}

resource "aws_security_group" "eks-node-group-sg" {
    name = "eks-node-group-sg"
    description = "Security group for EKS cluster worked nodes"
    vpc_id = aws_vpc.eks-vpc.id
    ingress {
        description = "Allow HTTPS"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }
    ingress {
        description = "Allow HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Kubernetes Ports"
        from_port = 30000
        to_port = 32767
        protocol = "custom-tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Custom Ports"
        from_port = 8000
        to_port = 9000
        protocol = "custom-tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Jump SG"
        from_port = 22
        to_port = 22
        protocol = "ssh"
        cidr_blocks = ["sg-09eba347d9647b1e4"]
    }
}

resource "aws_eks_cluster" "eks-cluster" {
    name = "my-prod-cluster"
    role_arn = aws_iam_role.eks-cluster-role.arn
    vpc_config {
        subnet_ids = [
            aws_subnet.eks-public-subnet-1.id,
            aws_subnet.eks-public-subnet-2.id,
            aws_subnet.eks-private-subnet-1.id,
            aws_subnet.eks-private-subnet-2.id
        ]
        cluster_security_group_id = aws_security_group.eks-sg.id      
    }

}

resource "aws_eks_node_group" "eks-node-group" {
    cluster_name = aws_eks_cluster.eks-cluster.name
    node_group_name = "my-prod-node-group"
    node_role_arn = aws_iam_role.eks_node_group_role.arn
    ami_type = "AL2023_x86_64_STANDARD"
    capacity_type = "ON_DEMAND"
    instance_types = ["c7i-flex.large"]
    subnet_ids = [
        aws_subnet.eks-public-subnet-1.id,
        aws_subnet.eks-public-subnet-2.id
    ]
    scaling_config {
        desired_size = 2
        max_size = 3
        min_size = 1
    }
    depends_on = [ aws_iam_role.eks_node_group_role ]
    security_group_ids = [aws_security_group.eks-sg.id]
}