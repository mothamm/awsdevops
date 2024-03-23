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

def create_vpc():
    if existing_vpcs['Vpcs']:
        vpc_id = existing_vpcs['Vpcs'][0]['VpcId']
        print(f"CIDR exists already: {ipcidr}. \nVPC ID is: {vpc_id}")
        # print(f"Proceeding to delete the VPC: {vpc_id} ...")
        # response = client.delete_vpc (VpcId = vpc_id)
        # print(f"Successfully Deleted {vpc_id} .... Exiting!!")
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

def modify_vpc(vpc_id):
    try:
        response = client.modify_vpc_attribute(
        EnableDnsHostnames = {'Value':True},
        VpcId = vpc_id
        )
        print("Modified VPC attributes for VPC:", vpc_id)
        return response
    except Exception as e:
        print(f"Failed to modify attributes for VPC {vpc_id} as {e}")
        return None

vpc_id = create_vpc()
if vpc_id:
    modify_vpc(vpc_id)