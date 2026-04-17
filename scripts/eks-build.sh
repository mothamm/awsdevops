#!/bin/bash

VPCID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)
aws ec2 create-tags --resources "$VPCID" --tags Key=Name,Value=eks-vpc
aws ec2 modify-vpc-attribute --vpc-id "$VPCID" --enable-dns-support 
aws ec2 modify-vpc-attribute --vpc-id "$VPCID" --enable-dns-hostnames

PUBLIC_SUBNET1=$(aws ec2 create-subnet --vpc-id "$VPCID" --cidr-block 10.0.1.0/24 --query 'Subnet.SubnetId' --availability-zone us-east-1a --output text)
aws ec2 create-tags --resources "$PUBLIC_SUBNET1" --tags Key=Name,Value=eks-public-subnet-1
aws ec2 modify-subnet-attribute --subnet-id "$PUBLIC_SUBNET1" --map-public-ip-on-launch

PUBLIC_SUBNET2=$(aws ec2 create-subnet --vpc-id "$VPCID" --cidr-block 10.0.2.0/24 --query 'Subnet.SubnetId' --availability-zone us-east-1b --output text)
aws ec2 create-tags --resources "$PUBLIC_SUBNET2" --tags Key=Name,Value=eks-public-subnet-2
aws ec2 modify-subnet-attribute --subnet-id "$PUBLIC_SUBNET2" --map-public-ip-on-launch

IGWID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
aws ec2 attach-internet-gateway --vpc-id "$VPCID" --internet-gateway-id "$IGWID"

ROUTETABLEID=$(aws ec2 create-route-table --vpc-id "$VPCID" --query 'RouteTable.RouteTableId' --output text)  
aws ec2 create-route --route-table-id "$ROUTETABLEID" --destination-cidr-block 0.0.0.0/0 --gateway-id "$IGWID"
aws ec2 associate-route-table --route-table-id "$ROUTETABLEID" --subnet-id "$PUBLIC_SUBNET1"
aws ec2 associate-route-table --route-table-id "$ROUTETABLEID" --subnet-id "$PUBLIC_SUBNET2"

# aws ec2 create-security-group --group-name eks-cluster-sg --description "Security group for EKS cluster" \
#     --vpc-id "$VPCID" --inbound-rules "IpProtocol=HTTPS,FromPort=443,ToPort=443,CidrIp=10.0.0.0/16" \
#     --query 'GroupId' --output text


aws eks create-cluster --name eks-cluster --role-arn arn:aws:iam::123456789012:role/eks-cluster-role \
    --resources-vpc-config subnetIds=$PUBLIC_SUBNET1,$PUBLIC_SUBNET2 --securityGroupIds=$(aws ec2 create-security-group --group-name eks-cluster-sg --description "Security group for EKS cluster" \
    --vpc-id "$VPCID" --inbound-rules "IpProtocol=HTTPS,FromPort=443,ToPort=443,CidrIp=10.0.0.0/16" \
    --query 'GroupId' --output text)

# aws eks create-nodegroup --cluster-name eks-cluster --nodegroup-name eks-node-group --node-role arn:aws:iam::123456789012:role/eks-node-group-role --subnets $PUBLIC_SUBNET1 $PUBLIC_SUBNET2 --scaling-config minSize=1,maxSize=3,desiredSize=2
# aws eks update-kubeconfig --name eks-cluster
# aws eks describe-cluster --name eks-cluster --query 'cluster.status' --output text
# aws eks describe-nodegroup --cluster-name eks-cluster --nodegroup-name eks-node-group --query 'nodegroup.status' --output text
# aws eks list-nodegroups --cluster-name eks-cluster
# aws eks describe-nodegroup --cluster-name eks-cluster --nodegroup-name eks-node-group --query 'nodegroup.instances' --output text