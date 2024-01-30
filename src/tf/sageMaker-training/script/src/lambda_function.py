import os
import zipfile

import boto3
import sagemaker
from sagemaker.tensorflow import TensorFlow

s3 = boto3.client('s3')
sm = boto3.client('sagemaker')

script_s3_key = os.environ['script_s3_key']
script_s3_bucket = os.environ['script_s3_bucket']
sagemaker_role_arn = os.environ['sagemaker_role_arn']
s3.download_file(script_s3_bucket, script_s3_key, f"/tmp/{script_s3_key}")
with zipfile.ZipFile(f"/tmp/{script_s3_key}", 'r') as f:
    f.extractall('/tmp/')
os.system(f"rm /tmp/{script_s3_key}")

def lambda_handler(event, context):
    estimator = TensorFlow(
        entry_point="/tmp/train.py",
        role=sagemaker_role_arn,
        instance_count=1,
        instance_type="ml.p3.2xlarge",
        framework_version="2.1.0",
        py_version="py3",
        # distribution={"parameter_server": {"enabled": True}},
    )
    estimator.fit(
        "s3://sagemaker-training-script-experiment/data.zip",
        wait=False
    )
