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

#Create a VPC after checking if there is any existing VPC with CIDR
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
    
#Create Subnets based on the number CIDR blocks mentioned
def create_subnet(CidrBlock, VpcId, AvailabilityZone):
    subnet = client.create_subnet(
        TagSpecifications = [{ 'ResourceType': 'subnet', 'Tags':[{ 'Key': 'Name', 'Value': 'Boto3'}], }],
        CidrBlock = CidrBlock,
        AvailabilityZone = AvailabilityZone,
        VpcId = VpcId
    )
    print(subnet['Subnet']['SubnetId'])
    return CidrBlock, VpcId, AvailabilityZone

#Describing subnets and storing them into list for future access such as subnet association with route-tables.
def describe_subnets(vpc_id):
    filter = [{'Name':'vpc-id', 'Values':[vpc_id]}]
    try:
        response = client.describe_subnets(Filters=filter)
        subnets = response['Subnets']
        subnet_list = []
        for subnet in subnets:
            subnet_info = subnet['SubnetId']
            subnet_list.append(subnet_info)
        # print(subnet_list)
        return subnet_list
    except ClientError as e:
        print(f"Error describing subnets: {e}")
        return None

#Check if the created VPC has any IGW attached and then create a new IGW and attach it to VPC
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

#Associating the IGW with Route Table
def igw_assoc_rtb(vpc_id, igw_id):
    
    try:
        filter = [{'Name':'vpc-id', 'Values':[vpc_id]}]
        get_rtb = client.describe_route_tables(Filters = filter)

        if get_rtb['RouteTables']:
            rtb = get_rtb['RouteTables'][0]
            for association in rtb['Associations']:
                if association['Main']:
                    rtb_id = rtb['RouteTableId']
                    routes_rtb = client.create_route(
                        RouteTableId = rtb_id,
                        DestinationCidrBlock = '0.0.0.0/0',
                        GatewayId = igw_id
                    )
                    print(f"Main route table attached to VPC {vpc_id}. RTB ID: {rtb_id}. With IGW ID: {igw_id}")
                    return vpc_id, igw_id, rtb_id
            rtb_id = rtb['Associations'][0]['RouteTableId']
            print(f"Route table attached to VPC {vpc_id}. RTB ID: {rtb_id}")
            return rtb_id
        else:
            print(f"No route tables found for VPC {vpc_id}")
            return None
    except ClientError as e:
        logging.error(e)
        return False  

def sub_assoc_rtb(subnets):
    try:
        filter = [{'Name':'vpc-id', 'Values':[vpc_id]}]
        get_rtb = client.describe_route_tables(Filters = filter)

        if get_rtb['RouteTables']:
            rtb = get_rtb['RouteTables'][0]
            for association in rtb['Associations']:
                if association['Main']:
                    rtb_id = rtb['RouteTableId']

        for subnet in subnetsList[:3]:
            rtb_routes = client.associate_route_table(RouteTableId = rtb_id, SubnetId = subnet)
            print(f" Subnet {subnet} associated with Route table {rtb_id}")
        return subnet, rtb, rtb_id
    except ClientError as e:
        print(f"Error associating subnets with route table: {e}")


#Functions execution
vpc_id = create_vpc()
if vpc_id:
    for az, cidr in enumerate(subcidr):
        create_subnet(cidr, vpc_id, availablity_zones[az])
    igw_id, vpc_id = create_attach_igw(vpc_id)
    igw_assoc_rtb(vpc_id, igw_id)
    subnetsList = describe_subnets(vpc_id)
    if subnetsList:
        sub_assoc_rtb(subnetsList)