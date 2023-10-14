import boto3

BASE_DOMAIN = 'freecaretoday.com'
TABLE_NAME = 'dns_record_catalog'
allowed_modes = ['set', 'get', 'del']
r53 = boto3.client('route53')
dynamodb = boto3.client("dynamodb")

def retrieve_dns_record(subdomain_name: str):
    response = dynamodb.get_item(
        TableName=TABLE_NAME,
        Key={'subdomain_name': {'S': subdomain_name}}
    )
    return response

def create_record_from_scratch(base_zone_id: str, subdomain_name: str, ip: str):
    resp = r53.create_hosted_zone(
            Name=subdomain_name,
            CallerReference=subdomain_name.replace(".","")
        )
    sub_records = [{'Value': val} for val in resp['DelegationSet']['NameServers']]
    resp1 = r53.change_resource_record_sets(
            ChangeBatch={
                'Changes': [
                    {
                        'Action': 'CREATE',
                        'ResourceRecordSet': {
                            'Name': subdomain_name,
                            'ResourceRecords': sub_records,
                            'TTL': 60,
                            'Type': 'NS',
                            },
                        },
                    ],
            },
            HostedZoneId=base_zone_id.replace('/hostedzone/',''),
        )
    resp2 = r53.change_resource_record_sets(
            ChangeBatch={
                'Changes': [
                    {
                        'Action': 'CREATE',
                        'ResourceRecordSet': {
                            'Name': subdomain_name,
                            'ResourceRecords': [{'Value': ip}],
                            'TTL': 300,
                            'Type': 'A',
                            },
                        },
                    ],
            },
            HostedZoneId=resp['HostedZone']['Id'].replace('/hostedzone/',''),
        )
    dynamodb.put_item(
        TableName=TABLE_NAME,
        Item={
            'subdomain_name':{'S':subdomain_name},
            'zone_id':{'S':resp['HostedZone']['Id'].replace('/hostedzone/','')}
        }
    )

def update_existing_record(sub_zone_id: str, subdomain_name: str, ip: str):
    # if hosted zone exists, update only
    resp3 = r53.change_resource_record_sets(
            ChangeBatch={
                'Changes': [
                        {
                            'Action': 'UPSERT',
                            'ResourceRecordSet': {
                                'Name': subdomain_name,
                                'Type': 'A',
                                'TTL': 300,
                                'ResourceRecords': [{'Value': ip}]
                            }
                        }
                ]
            },
            HostedZoneId=sub_zone_id.replace('/hostedzone/',''),
        )


def lambda_handler(event, context):
    method = 'set'
    subdomain = 'ddns12'
    ddns_record = f'{subdomain}.{BASE_DOMAIN}'
    ip = '84.64.54.43'
    # ip = '192.168.1.1'
    hzones = r53.list_hosted_zones()['HostedZones']
    print("hzones", hzones)
    response = retrieve_dns_record(BASE_DOMAIN)
    id_target = response['Item']['zone_id']['S'] # base domain zone id
    print("response: ", f"{BASE_DOMAIN}", response,)
    # for i in range(len(hzones)):
    #     if hzones[i]['Name'] == f'{BASE_DOMAIN}.':
    #         id_target = hzones[i]['Id']
    #         records = r53.list_resource_record_sets(HostedZoneId=id_target)
    #         print(records['ResourceRecordSets'])
    #         print(records)

    if method == 'set':
        sub_resp = retrieve_dns_record(ddns_record)
        print(sub_resp)
        if 'Item' not in sub_resp:
            print("No sub domain found... So create new one...")
            create_record_from_scratch(id_target, ddns_record, ip)
        elif 'Item' in sub_resp:
            print("Sub domain found... So update existing one...")
            update_existing_record(sub_resp['Item']['zone_id']['S'], ddns_record, ip)
    elif method == 'get':
        pass
    elif method == 'del':
        resp = r53.delete_hosted_zone(Id='/hostedzone/Z0056405277KQ8LY0NH81')
        print(resp)
    else:
        pass
