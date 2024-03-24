import hashlib
import os
from datetime import datetime
from urllib.parse import quote
from uuid import uuid4

import boto3

ses = boto3.client('ses')
DOMAIN_NAME = os.environ["DOMAIN_NAME"]
AUTH_CODE_SALT = os.environ["AUTH_CODE_SALT"]
sender = f"no-reply@{DOMAIN_NAME}"


def lambda_handler(event, context):
    print(event)
    email = event["request"]["userAttributes"]["email"]

    auth_challenge = uuid4().hex
    salted_code = f"{os.environ['AUTH_CODE_SALT']}{auth_challenge}"
    hashed_code = hashlib.sha256(salted_code.encode()).hexdigest()

    event["response"] = {}
    # public sent to app
    event["response"]["publicChallengeParameters"] = {"email": email}

    # private only used for verify auth
    event["response"]["privateChallengeParameters"] = {}
    event["response"]["privateChallengeParameters"]["answer"] = hashed_code
    event["response"]["privateChallengeParameters"]["timestamp"] = int(
        datetime.utcnow().timestamp()
    )

    url_encoded_email = quote(email)
    url = f"https://{DOMAIN_NAME}/login/?code={auth_challenge}&email={url_encoded_email}"

    ses.send_email(
        Source=sender,
        Destination = {
            "ToAddresses": [
                email
            ]
        },
        Message={
            "Subject": {
                "Data": "Login Link for Drugig Website",
                "Charset": "UTF-8"
            },
            "Body": {
                "Html": {
                    "Data": f"{url}",
                    "Charset": "UTF-8"
                }
            }
        }
    )
    print(f"[INFO] USER EVENT: Link issued to {email}")

    return event
