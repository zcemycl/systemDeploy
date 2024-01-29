import os
import zipfile

import boto3

s3 = boto3.client('s3')
sm = boto3.client('sagemaker')

script_s3_key = os.environ['script_s3_key']
script_s3_bucket = os.environ['script_s3_bucket']
s3.download_file(script_s3_bucket, script_s3_key, f"/tmp/{script_s3_key}")
with zipfile.ZipFile(f"/tmp/{script_s3_key}", 'r') as f:
    f.extractall('/tmp/')
os.system(f"rm /tmp/{script_s3_key}")

def lambda_handler(event, context):
    pass
