import boto3
import json

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

def delete_existing_record(base_zone_id: str, sub_zone_id: str, subdomain_name: str):
    records = r53.list_resource_record_sets(
        HostedZoneId=base_zone_id,
        StartRecordName=subdomain_name,
        StartRecordType='NS'
    )
    print(records)
    resp1 = r53.change_resource_record_sets(
        ChangeBatch={
            'Changes': [
                {
                    'Action': 'DELETE',
                    'ResourceRecordSet': records['ResourceRecordSets'][0],
                    },
                ],
        },
        HostedZoneId=base_zone_id.replace('/hostedzone/',''),
    )
    records2 = r53.list_resource_record_sets(
        HostedZoneId=sub_zone_id,
        StartRecordName=subdomain_name,
        StartRecordType='A'
    )
    print(records2)
    resp2 = r53.change_resource_record_sets(
        ChangeBatch={
            'Changes': [
                {
                    'Action': 'DELETE',
                    'ResourceRecordSet': records2['ResourceRecordSets'][0]

                }
                ],
        },
        HostedZoneId=sub_zone_id.replace('/hostedzone/',''),
    )
    resp3 = r53.delete_hosted_zone(
        Id=f"/hostedzone/{sub_zone_id.replace('/hostedzone/','')}"
    )
    dynamodb.delete_item(
        TableName=TABLE_NAME,
        Key={
            'subdomain_name':{'S':subdomain_name},
        }
    )

def lambda_handler(event, context):
    if event['queryStringParameters'] == None:
        return {'statusCode': 422, 'body': 'missing query string parameters'}
    if 'method' not in event['queryStringParameters']:
        return {'statusCode': 422, 'body': 'missing query string parameters -- method get del set'}
    if 'subdomain' not in event['queryStringParameters']:
        return {'statusCode': 422, 'body': 'missing query string parameters -- subdomain {xxx}.freecaretoday.com'}
    if 'ip' not in event['queryStringParameters']:
        ip = None
    else:
        ip = event['queryStringParameters']['ip']
    method = event['queryStringParameters']['method']
    subdomain = event['queryStringParameters']['subdomain']
    if method in ['set'] and ip == None:
        return {'statusCode': 422, 'body': 'missing query string parameters -- ip and some methods are not compatible'}
    if method not in allowed_modes:
        return {'statusCode': 422, 'body': 'wrong query string parameters -- method get del set'}
    ddns_record = f'{subdomain}.{BASE_DOMAIN}'
    hzones = r53.list_hosted_zones()['HostedZones']
    print("hzones", hzones)
    response = retrieve_dns_record(BASE_DOMAIN)
    id_target = response['Item']['zone_id']['S'] # base domain zone id
    print("response: ", f"{BASE_DOMAIN}", response,)
    sub_resp = retrieve_dns_record(ddns_record)
    print(sub_resp)
    if method == 'set':
        if 'Item' not in sub_resp:
            print("No sub domain found... So create new one...")
            create_record_from_scratch(id_target, ddns_record, ip)
            return {
                'statusCode': 200,
                'body': f"SET Subdomain {ddns_record} not found. Created from scratch."
            }
        elif 'Item' in sub_resp:
            print("Sub domain found... So update existing one...")
            update_existing_record(sub_resp['Item']['zone_id']['S'], ddns_record, ip)
            return {
                'statusCode': 200,
                'body': f"SET Subdomain {ddns_record} found. Updated record."
            }
    elif method == 'get':
        if 'Item' not in sub_resp:
            return {'statusCode': 404, 'body': f"GET Subdomain {ddns_record} not found. "}
        elif 'Item' in sub_resp:
            records = r53.list_resource_record_sets(
                HostedZoneId=sub_resp['Item']['zone_id']['S'],
                StartRecordName=ddns_record,
                StartRecordType='A'
            )
            print('GET Subdomain info, ', records['ResourceRecordSets'][0])
            return {
                'statusCode': 200,
                # 'message': f"GET Subdomain {ddns_record} found. ",
                'body': json.dumps(records['ResourceRecordSets'][0])
            }
    elif method == 'del':
        if 'Item' not in sub_resp:
            return {'statusCode': 404, 'body': f"DEL Subdomain {ddns_record} not found. "}
        delete_existing_record(id_target, sub_resp['Item']['zone_id']['S'], ddns_record)
        return {
            'statusCode': 200,
            'body': f"DEL Subdomain {ddns_record} found. ",
        }
