output "aws_ami_id" {
  value = data.aws_ami.amazon-linux.id
}

output "my_public_ip" {
  value = aws_instance.Server.public_ip
}

output "my_vpc_id" {
  value = aws_vpc.MyInfra-vpc.id
}
