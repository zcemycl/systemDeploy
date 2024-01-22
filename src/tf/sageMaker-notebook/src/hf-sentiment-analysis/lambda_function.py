import csv
import io
import json
import os

import boto3

ENDPOINT_NAME = "huggingface-pytorch-inference-2023-12-22-02-20-44-698"
runtime= boto3.client('runtime.sagemaker')


def lambda_handler(event, context):
    print(event)
    user_dict = {"inputs": ["I like you. I love you", "life is bad"]}
    inp = json.dumps(user_dict).encode()
    response = runtime.invoke_endpoint(EndpointName=ENDPOINT_NAME,
            ContentType='application/json',
            Body=inp)
    out = json.loads(response['Body'].read().decode())
    print(out)
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
