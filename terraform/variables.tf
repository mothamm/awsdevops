variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "env_prefix" {}
variable "avail_zone" {}
variable "myip" {}
variable "myports" {}
variable "instance_type" {}
variable "public_key_location" {
    type = string
    sensitive = true
}
