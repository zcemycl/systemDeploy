import argparse

import boto3
import requests

r53 = boto3.client("route53")

resp = requests.get("http://checkip.amazonaws.com")
public_ip = resp.text.strip()

hz = r53.list_hosted_zones()

p = argparse.ArgumentParser()
p.add_argument("--domain", type=str, default="freecaretoday.com")
p.add_argument("--subdomain", type=str, default="vpn.freecaretoday.com")
args = p.parse_args()

hz_id = [each["Id"] for each in hz["HostedZones"] if each["Name"] == f"{args.domain}."][0]
print(hz_id)

resp3 = r53.change_resource_record_sets(
    ChangeBatch={
        "Changes": [
            {
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": args.subdomain,
                    "Type": "A",
                    "TTL": 60,
                    "ResourceRecords": [{"Value": public_ip}],
                },
            }
        ]
    },
    HostedZoneId=hz_id.replace("/hostedzone/", ""),
)
