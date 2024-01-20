import csv
import io
import json
import os

import boto3

ENDPOINT_NAME = os.environ["endpoint_name"]
runtime= boto3.client('runtime.sagemaker')


def lambda_handler(event, context):
    print(event)
    response = runtime.invoke_endpoint(EndpointName=ENDPOINT_NAME,
            # ContentType='application/json',
            Body="Hello")
    out = json.loads(response['Body'].read().decode())
    print(out)
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
