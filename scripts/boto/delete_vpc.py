from ast import Attribute
import boto3

# class color:
#    PURPLE = '\033[95m'
#    CYAN = '\033[96m'
#    DARKCYAN = '\033[36m'
#    BLUE = '\033[94m'
#    GREEN = '\033[92m'
#    YELLOW = '\033[93m'
#    RED = '\033[91m'
#    BOLD = '\033[1m'
#    UNDERLINE = '\033[4m'
#    END = '\033[0m'

'''This code checks if there is an existing vpc with the CIDR.
   If there is no VPC with given CIDR it proceeds to create one and enables the DNS hostnames.
'''

client = boto3.client('ec2')

ipcidr = '10.1.0.0/18'

#Checking if the VPC with CIDR block mentioned above exists
existing_vpcs = client.describe_vpcs(
    Filters=[
        {
            'Name': 'cidr',
            'Values': [ipcidr]
        }
    ]
)

def delete_vpc():
    if existing_vpcs['Vpcs']:
        vpc_id = existing_vpcs['Vpcs'][0]['VpcId']
        print(f"CIDR exists: {ipcidr}. \nVPC ID is: {vpc_id}")
        print(f"Proceeding to delete the VPC: {vpc_id} ...")
        response = client.delete_vpc (VpcId = vpc_id)
        print(f"Successfully Deleted {vpc_id}.\nExiting...!")
    else:
        print(f"CIDR does not exist: {ipcidr}. \nExiting...!")

delete_vpc()

# def get_vpc():
#     vpc_ids = client.describe_vpcs()['Vpcs']
#     for vpcid in vpc_ids:
#         print(vpcid['VpcId'] + " -- " + vpcid['CidrBlock'])
   
# # get_vpc()

# def get_rvpc():
#     vpc = client.describe_vpc_attribute(
#         Attribute = 'enableDnsSupport',
#         VpcId = 'vpc-0f6fa630dc0d1349d'  
#     )
#     print(vpc)
# get_rvpc()