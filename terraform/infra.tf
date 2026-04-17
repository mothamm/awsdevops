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
