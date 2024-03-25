def lambda_handler(event, context):
    print(event)
    num_of_session = len(event["request"]["session"])
    request = event["request"]
    session = request["session"]
    if "userNotFound" in event["request"] and request["userNotFound"]:
        event["response"]["issueTokens"] = False
        event["response"]["failAuthentication"] = True
        print(f"[INFO] USER EVENT: Unauthorized user {event['userName']} login. ")
    elif num_of_session != 0:
        if num_of_session >= 5 and not session[-1]["challengeResult"]:
            event["response"]["issueTokens"] = False
            event["response"]["failAuthentication"] = True
            print(f"[INFO] USER EVENT: user {event['userName']} attempted too much times. ")
        elif session[-1]["challengeName"] == "CUSTOM_CHALLENGE" and session[-1]["challengeResult"]:
            event["response"]["issueTokens"] = True
            event["response"]["failAuthentication"] = False
            event["response"]["challengeName"] = 'CUSTOM_CHALLENGE'
    else:
        event["response"]["issueTokens"] = False
        event["response"]["failAuthentication"] = False
        event["response"]["challengeName"] = 'CUSTOM_CHALLENGE'

    return event
