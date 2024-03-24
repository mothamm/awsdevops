import boto3, os, logging, json, botocore, requests
from botocore.exceptions import ClientError

s3 = boto3.client('s3')

bucket_name = "<YOUR-BUCKET-NAME HERE>"
region = "us-east-2" # If you're creating the resources is `US-EAST-1` then this variable is not required.

#Creating a bucket
def create_bucket(bucket_name, region=None):
    try:
        if region is None:
            s3_client = boto3.client('s3')
            s3_client.create_bucket(Bucket=bucket_name)
    except ClientError as e:
        logging.error(e)
        return False
    return True
# create_bucket(bucket_name)

#Uploading the file as an object - USE case if for multi-part uploads
def upload_file_object(file_name, bucket_name, fobj_name=None):
    if fobj_name is None:
        fobj_name = os.path.basename(file_name)

    try:
        with open(file_name, "rb") as f:
            s3.upload_fileobj(f, bucket_name, fobj_name)
    except ClientError as e:
        logging.error(e)
        return False
    return True
# upload_file_object("./delete_vpc.py", bucket_name, "deletevpc.txt")

#Uploading the files to S3 Bucket
def Upload_file(file_name, bucket_name, obj_name):
    if obj_name is None:
        obj_name = os.path.basename(file_name)
    
    try:
        s3.upload_file(file_name, bucket_name, obj_name)
    except ClientError as e:
        logging.error(e)
        return False
    return True
# Upload_file("./delete_vpc.py", bucket_name, "deletevpc.py")

#Deleting an Empty Bucket
def delete_empty_bucket(bucket_name):
    response = s3.delete_bucket(Bucket=bucket_name)
    print (response)
# delete_empty_bucket(bucket_name)

#Deleting a Non-Empty Bucket
def delete_non_empty_bucket(bucket_name):
    s3 = boto3.resource('s3')
    bucketClient = s3.Bucket(bucket_name)
    bucketClient.objects.all().delete()
    bucketClient.meta.client.delete_bucket(Bucket = bucket_name)
# delete_non_empty_bucket(bucket_name)