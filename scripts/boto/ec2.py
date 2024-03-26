from re import sub, subn
import boto3
from botocore.exceptions import ClientError


# Initialize the EC2 client
client = boto3.client('ec2')
subcidr = ['10.1.0.1/28', '10.1.1.0/28', '10.1.2.0/28', '10.1.3.0/28', '10.1.4.0/28', '10.1.5.0/28']

def describe_subnets():
    def check_subnets(subnets):
        for subnet in subnets:
                if subnet['CidrBlock'] in subcidr:
                    print("Subnet already exists:", subnet['SubnetId'])
                    return subnet
                
        subs = client.describe_subnets(Filters=[{'Name': 'vpc-id', 'Values': ['vpc-058d24c28b97914e2']}])
        subnets = subs['Subnets']
        existing_subnet = check_subnets(subnets)
        if existing_subnet:a
            return existing_subnet
            
        subnet = client.create_subnet(
            TagSpecifications = [{ 'ResourceType': 'subnet', 'Tags':[{ 'Key': 'Name', 'Value': 'Boto3'}], }],
            CidrBlock = subcidr[0],
            AvailabilityZone = 'AvailabilityZone',
            VpcId = 'vpc-058d24c28b97914e2'
        )
        
        print(subnet['Subnet']['SubnetId'])
        return subnet['Subnet']
 

describe_subnets()