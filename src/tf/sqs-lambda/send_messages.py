import boto3

sqs = boto3.resource('sqs')

queue = sqs.get_queue_by_name(QueueName="leo-downstream-control")
messages = [f"mm{i}" for i in range(10)]
for msg in messages:
    resp = queue.send_message(MessageBody=msg)
    print(resp.get('MessageId'))
    print(resp.get('MD5OfMessageBody'))
