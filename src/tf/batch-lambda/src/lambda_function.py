import json
import os
import time

import boto3

jobQ = os.environ["JOBQ"]
jobDef = os.environ["JOBDEF"]

bj = boto3.client('batch')

def lambda_handler(event, context):
    jobName = f"leo-trial-batch-{int(time.time())}"
    _ = bj.submit_job(
            jobName=jobName,
            jobQueue=jobQ,
            jobDefinition=jobDef,
        )
    return {
        'statusCode': 200,
        'body': json.dumps(jobName)
    }
