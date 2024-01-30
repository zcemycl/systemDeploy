import os
import time
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
os.system(f"chmod +x /tmp/train.py")

def lambda_handler(event, context):
    start_time = time.time()
    estimator = TensorFlow(
        base_job_name=f"leo-try-training-{int(time.time())}",
        entry_point="train.py",
        source_dir="/tmp",
        # source_dir="/home/ec2-user/SageMaker",
        role=sagemaker_role_arn,
        instance_count=1,
        instance_type="ml.c5.xlarge",
        hyperparameters={"epochs": 10},
        framework_version="2.13.0",
        py_version="py310",
        output_path=f"s3://{script_s3_bucket}/model",
        # image_name="763104351884.dkr.ecr.eu-west-2.amazonaws.com/tensorflow-training:2.13.0-cpu-py310-ubuntu20.04-ec2",
        script_mode=True,
        input_mode="File"
        # distribution={"parameter_server": {"enabled": True}},
    )
    estimator.fit(f"s3://{script_s3_bucket}/data", wait=False)
    end_time = time.time()
    print(f"Training job initialisation takes: {(end_time-start_time)/60} min")
