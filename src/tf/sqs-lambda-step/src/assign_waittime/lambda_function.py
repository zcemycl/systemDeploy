import json
import math
import os
import time

import boto3
from boto3.dynamodb.conditions import Key

DELAY_INTERVAL = int(os.environ['delay_interval'])
state_arn = os.environ["step_arn"]
TABLE_NAME = os.environ["TABLE_NAME"]

client = boto3.client('stepfunctions')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(TABLE_NAME)
cache = {}


def lambda_handler(event, context):
    messages = [e["body"] for e in event["Records"]]
    print(messages)
    # GET previous timestamp to schedule calls in order
    if 'counter_val' in cache:
        last_timestamp = cache['counter_val']
    else:
        resp = table.query(Select='ALL_ATTRIBUTES',
            KeyConditionExpression=Key('counter_key').eq('0') & Key('counter_val').gte(0),
            ScanIndexForward=False, Limit=1)
        last_timestamp = int(resp['Items'][0]['counter_val'])
    cur_timestamp = time.time()
    time_dif = cur_timestamp - last_timestamp
    if time_dif > DELAY_INTERVAL:
        # no one ahead
        base_wait = 0
    else:
        # still in calls
        base_wait = max(time_dif, 0)
    # queue message to wait n seconds in order to make calls
    for i, msg in enumerate(messages):
        _ = client.start_execution(
            stateMachineArn=state_arn,
            input=json.dumps({
                'key1': msg,
                'waitTime': math.ceil(base_wait+i*DELAY_INTERVAL)
            })
        )

    # Cache of last timestamp
    final_timestamp = math.ceil(cur_timestamp+base_wait+(i+1)*DELAY_INTERVAL)
    cache['counter_val'] = final_timestamp
    table.put_item(Item={
        'counter_key': "0",
        'counter_val': final_timestamp
    })
    print(cur_timestamp, last_timestamp, final_timestamp)
