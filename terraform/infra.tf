resource "aws_vpc" "MyInfra-vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
    
  tags = {
    "Name" = "${var.env_prefix}-MyInfra"
  }
}

resource "aws_internet_gateway" "MyInfra-IGW" {
  vpc_id = aws_vpc.MyInfra-vpc.id
}

resource "aws_subnet" "MyInfra-pub1" {
  vpc_id = aws_vpc.MyInfra-vpc.id
  cidr_block = var.subnet_cidr_block[0]
  availability_zone = var.avail_zone[0]
  
  tags = {
    "Name" = "${var.env_prefix}-MyInfra"
  }
}

resource "aws_subnet" "MyInfra-pub2" {
  vpc_id = aws_vpc.MyInfra-vpc.id
  cidr_block = var.subnet_cidr_block[1]
  availability_zone = var.avail_zone[1]
  
  tags = {
    "Name" = "${var.env_prefix}-MyInfra"
  }
}

resource "aws_subnet" "MyInfra-pub3" {
  vpc_id = aws_vpc.MyInfra-vpc.id
  cidr_block = var.subnet_cidr_block[2]
  availability_zone = var.avail_zone[2]
  
  tags = {
    "Name" = "${var.env_prefix}-MyInfra"
  }
}

resource "aws_default_route_table" "MyInfra" {
  default_route_table_id = aws_vpc.MyInfra-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MyInfra-IGW.id
  } 

   tags = {
    "Name" = "${var.env_prefix}-MyInfra-rtb"
  }
}

resource "aws_default_security_group" "MyInfra-sg" {
  vpc_id = aws_vpc.MyInfra-vpc.id

  ingress {
    from_port = var.myports[0]
    to_port = var.myports[0]
    protocol = "tcp"
    cidr_blocks = var.myip
    }

  ingress {
    from_port = var.myports[1]
    to_port = var.myports[1]
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = var.myports[2]
    to_port = var.myports[2]
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${var.env_prefix}-sg"
  }
}


resource "aws_key_pair" "infra-key" {
  key_name = "${var.env_prefix}-key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "Server" {
  ami = data.aws_ami.amazon-linux.id  
  instance_type = var.instance_type
  
  subnet_id = aws_subnet.MyInfra-pub1.id
  vpc_security_group_ids = [aws_default_security_group.MyInfra-sg.id]

  associate_public_ip_address = true

  key_name = aws_key_pair.infra-key.key_name 

  tags = {
    "Name" = "${var.env_prefix}-server"
  }
}