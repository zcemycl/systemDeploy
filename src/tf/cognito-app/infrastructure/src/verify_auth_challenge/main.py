import hashlib
import os
from datetime import datetime

AUTH_CODE_SALT = os.environ["AUTH_CODE_SALT"]
AUTH_TIMEOUT = os.environ["AUTH_TIMEOUT"]

def lambda_handler(event, context):
    print(event)
    email = event["request"]["userAttributes"]["email"]
    # from user
    answer_from_link = event["request"]["challengeAnswer"]
    salted_ans_link = AUTH_CODE_SALT+answer_from_link
    hashed_salted_ans_link = hashlib.sha256(salted_ans_link.encode()).hexdigest()
    # from create auth challenge
    hashed_answer = event["request"]["privateChallengeParameters"]["answer"]
    auth_req_timestamp = event["request"]["privateChallengeParameters"]["timestamp"]

    if hashed_answer == hashed_salted_ans_link:
        is_timeout = int(auth_req_timestamp)+int(AUTH_TIMEOUT) > int(datetime.utcnow().timestamp())
        event["response"]["answerCorrect"] = is_timeout
        print(f"[INFO] USER EVENT: {email} verify result -- {is_timeout}.")
        return event
    else:
        event["response"]["answerCorrect"] = False
        print(f"[INFO] USER EVENT: {email} verify result -- False.")

    return event
