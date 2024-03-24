def lambda_handler(event, context):
    print(event)
    if "userNotFound" in event["request"] and event["request"]["userNotFound"]:
        event["response"]["failAuthentication"] = True
        event["response"]["issueTokens"] = False
        print(f"[INFO] USER EVENT: Unauthorized user {event['userName']} login. ")
    else:
        event["response"]["issueTokens"] = False
        event["response"]["failAuthentication"] = False
        event["response"]["challengeName"] = 'CUSTOM_CHALLENGE'

    return event
