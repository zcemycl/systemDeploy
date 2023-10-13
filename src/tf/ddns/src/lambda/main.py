import boto3

allowed_modes = ['set', 'get', 'del']
r53 = boto3.client('route53')

def lambda_handler(event, context):
    method = 'set'
    subdomain = 'aag'
    ddns_record = f'{subdomain}.freecaretoday.com'
    ip = '84.64.54.43'
    hzones = r53.list_hosted_zones()['HostedZones']
    print(hzones)
    for i in range(len(hzones)):
        if hzones[i]['Name'] == 'freecaretoday.com.':
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

        # if hosted zone exists, update only

        pass
    elif method == 'get':
        pass
    elif method == 'del':
        resp = r53.delete_hosted_zone(Id='/hostedzone/Z0056405277KQ8LY0NH81')
        print(resp)
    else:
        pass
