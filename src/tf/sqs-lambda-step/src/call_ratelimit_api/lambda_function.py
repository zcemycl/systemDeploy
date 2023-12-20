import random


def lambda_handler(event, context):
    print(event)
    if random.choices([0,1], weights=[4,6])[0]:
        raise ValueError("Bad Luck! Queue Again!")
    return event
