import boto3

ses = boto3.client('ses')
sender = "no-reply@freecaretoday.com"
receiver = "lyc010197@gmail.com"
subject = "hello world ses"
message = "hello world ses"
charset = 'UTF-8'

resp = ses.send_email(
    Source = sender,
    Destination = {
        'ToAddresses': [
            receiver
        ]
    },
    Message={
        'Subject': {
            'Data': subject,
            'Charset': charset
        },
        'Body': {
            'Text': {
                'Data': message,
                'Charset': charset
            },
            'Html': {
                'Data': message,
                'Charset': charset
            }
        }
    }
)

print(resp)
