import os

import requests

APIGW_INVOKE_URI = os.environ["APIGW_INVOKE_URI"]
X_API_KEY = os.environ["X_API_KEY"]
print(APIGW_INVOKE_URI, X_API_KEY)

if __name__ == "__main__":
    ip = requests.get("http://checkip.amazonaws.com/").content.decode('utf8')
    print(ip.strip())
    resp = requests.get(
        f"{APIGW_INVOKE_URI}?method=set&subdomain=ddns&ip={ip.strip()}",
        headers={'x-api-key': X_API_KEY}
    )
