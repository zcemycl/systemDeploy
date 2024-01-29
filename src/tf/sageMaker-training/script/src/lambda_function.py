import os
import zipfile

import boto3

s3 = boto3.client('s3')
sm = boto3.client('sagemaker')

s3.download_file('sagemaker-training-script-experiment', 'train.zip', '/tmp/train.zip')
with zipfile.ZipFile('/tmp/train.zip', 'r') as f:
    f.extractall('/tmp/')
os.system('rm /tmp/train.zip')

def lambda_handler(event, context):
    pass
