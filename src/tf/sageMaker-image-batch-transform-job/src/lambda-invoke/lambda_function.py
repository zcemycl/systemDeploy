import csv
import io
import json
import os
import time

import boto3

MODEL_NAME = os.environ["model_name"]
sagemaker_client = boto3.client('sagemaker')


def lambda_handler(event, context):
    transform_job_name = f"leo-dummy-{round(time.time())}"
    req = {
        "TransformJobName": transform_job_name,
        "ModelName": MODEL_NAME,
        "MaxPayloadInMB": 1,
        "BatchStrategy": "MultiRecord",
        "Environment": {},
        "TransformInput": {
            "DataSource": {
                "S3DataSource": {
                    "S3DataType": "S3Prefix",
                    "S3Uri": "s3://dummy-batch-transform-job-bucket/inputs/raw.jsonl"
                }
            },
            # "ContentType": "text/csv",
            "SplitType": "Line",
            "CompressionType": "None"
        },
        "TransformOutput": {
            'S3OutputPath': "s3://dummy-batch-transform-job-bucket/outputs",
            "AssembleWith": "Line"
        },
        "TransformResources": {
            "InstanceType": "ml.m5.large",
            "InstanceCount": 1
        }
    }
    sagemaker_client.create_transform_job(**req)
    resp = sagemaker_client.describe_transform_job(
        **{"TransformJobName": transform_job_name}
    )
    print(resp)

    return transform_job_name
