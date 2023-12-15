import json
import random


def lambda_handler(event, context):
    print("trigger ...")
    messages = [e["body"] for e in event["Records"]]
    if random.choices([0,1], weights=[9,1])[0]:
        print("FAILURE... ", messages)
        raise ValueError('stuff not in content')
    else:
        print("SUCCESS... ", messages)
