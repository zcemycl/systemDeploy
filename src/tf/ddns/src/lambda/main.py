import boto3

BASE_DOMAIN = 'freecaretoday.com'
allowed_modes = ['set', 'get', 'del']
r53 = boto3.client('route53')

def lambda_handler(event, context):
    method = 'get'
    subdomain = 'aaj'
    ddns_record = f'{subdomain}.{BASE_DOMAIN}'
    ip = '84.64.54.43'
    hzones = r53.list_hosted_zones()['HostedZones']
    print(hzones)
    for i in range(len(hzones)):
        if hzones[i]['Name'] == f'{BASE_DOMAIN}.':
            id_target = hzones[i]['Id']
            records = r53.list_resource_record_sets(HostedZoneId=id_target)
            print(records['ResourceRecordSets'])
            print(records)

    if method == 'set':
        # if hosted zone does not exist, create
        resp = r53.create_hosted_zone(
            Name=ddns_record,
            CallerReference=ddns_record.replace(".","")
        )
        print(resp['HostedZone']['Id'])
        print(resp)
        print(resp['DelegationSet']['NameServers'])
        sub_records = [{'Value': val} for val in resp['DelegationSet']['NameServers']]
        print(sub_records)
        resp1 = r53.change_resource_record_sets(
            ChangeBatch={
                'Changes': [
                    {
                        'Action': 'CREATE',
                        'ResourceRecordSet': {
                            'Name':ddns_record,
                            'ResourceRecords': sub_records,
                            'TTL': 60,
                            'Type': 'NS',
                            },
                        },
                    ],
            },
            HostedZoneId=id_target.replace('/hostedzone/',''),
        )
        print(resp1)
        resp2 = r53.change_resource_record_sets(
            ChangeBatch={
                'Changes': [
                    {
                        'Action': 'CREATE',
                        'ResourceRecordSet': {
                            'Name': ddns_record,
                            'ResourceRecords': [{'Value': ip}],
                            'TTL': 300,
                            'Type': 'A',
                            },
                        },
                    ],
            },
            HostedZoneId=resp['HostedZone']['Id'].replace('/hostedzone/',''),
        )
        print(resp2)

        # if hosted zone exists, update only
        resp3 = r53.change_resource_record_sets(
            ChangeBatch={
                'Changes': [
                        {
                            'Action': 'UPSERT',
                            'ResourceRecordSet': {
                                'Name': ddns_record,
                                'Type': 'A',
                                'TTL': 300,
                                'ResourceRecords': [{'Value': '192.168.1.1'}]
                            }
                        }
                ]
            },
            HostedZoneId=resp['HostedZone']['Id'].replace('/hostedzone/',''),
        )
        print(resp3)
        pass
    elif method == 'get':
        pass
    elif method == 'del':
        resp = r53.delete_hosted_zone(Id='/hostedzone/Z0056405277KQ8LY0NH81')
        print(resp)
    else:
        pass
