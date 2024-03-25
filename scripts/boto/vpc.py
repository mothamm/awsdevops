from operator import sub
import resource
from urllib import response
from zoneinfo import available_timezones
import boto3, logging
from botocore.exceptions import ClientError

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
subcidr = ['10.1.0.1/28', '10.1.1.0/28', '10.1.2.0/28', '10.1.3.0/28', '10.1.4.0/28', '10.1.5.0/28']
availablity_zones = ['us-east-1a', 'us-east-1b', 'us-east-1c', 'us-east-1d', 'us-east-1e', 'us-east-1f']


#Checking if the VPC with CIDR block mentioned above exists
existing_vpcs = client.describe_vpcs(
    Filters=[
        {
            'Name': 'cidr',
            'Values': [ipcidr]
        }
    ]
)

def create_vpc():
    if existing_vpcs['Vpcs']:
        vpc_id = existing_vpcs['Vpcs'][0]['VpcId']
        print(f"CIDR exists already: {ipcidr}. \nVPC ID is: {vpc_id}")
        return vpc_id
    else:
        print(f"CIDR does not exist: {ipcidr}. \nCreating a new VPC...")
        response = client.create_vpc (
         CidrBlock = ipcidr,
         InstanceTenancy = 'default',
         TagSpecifications = [{
                'ResourceType': 'vpc',
                'Tags': [{'Key': 'Name','Value': 'VPC_Boto'}]
                }]
        )
        
        vpc_id = response['Vpc']['VpcId']
        print("Created new VPC with CIDR block:", ipcidr)
        print(f"VPC ID: {vpc_id}")
        return vpc_id

# def modify_vpc(vpc_id):
#     try:
#         response = client.modify_vpc_attribute(
#         EnableDnsHostnames = {'Value':True},
#         VpcId = vpc_id
#         )
#         print("Modified VPC attributes for VPC:", vpc_id)
#         return response
#     except Exception as e:
#         print(f"Failed to modify attributes for VPC {vpc_id} as {e}")
#         return None
    
def create_subnet(CidrBlock, VpcId, AvailabilityZone):
    subnet = client.create_subnet(
        TagSpecifications = [{ 'ResourceType': 'subnet', 'Tags':[{ 'Key': 'Name', 'Value': 'Boto3'}], }],
        CidrBlock = CidrBlock,
        AvailabilityZone = AvailabilityZone,
        VpcId = VpcId
    )
    print(subnet['Subnet']['SubnetId'])

def create_attach_igw(vpc_id):
    
    try:
        filter = [{'Name':'attachment.vpc-id', 'Values':[vpc_id]}]
        get_igw = client.describe_internet_gateways(Filters = filter)

        if get_igw['InternetGateways']:
            igw_id = get_igw['InternetGateways'][0]['InternetGatewayId']
            print(f"Internet Gateway already attached to VPC {vpc_id}. IGW ID: {igw_id}")
            return igw_id, vpc_id
        else:
            igw = client.create_internet_gateway()
            igw_id = igw['InternetGateway']['InternetGatewayId']
            igw_attach = client.attach_internet_gateway(
                InternetGatewayId = igw_id,
                VpcId = vpc_id
            )
            print(f"Internet Gateway {igw_id} created and attached to VPC {vpc_id}.")
            return igw_id, vpc_id
    except ClientError as e:
        logging.error(e)
        return False  

vpc_id = create_vpc()
if vpc_id:
     # for az, cidr in enumerate(subcidr):
     #     create_subnet(CidrBlock = cidr, VpcId=vpc_id, AvailabilityZone=availablity_zones[az])
    igw_id, vpc_id = create_attach_igw(vpc_id)