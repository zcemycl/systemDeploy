#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

export domain=${domain}
export subdomain=${subdomain}
sudo sed -i "/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf
sudo apt-get update
sudo apt-get upgrade -q -y | tee -a
sudo apt  install awscli -y
sudo apt install python3-pip -y
pip3 install boto3
echo "deb [signed-by=/etc/apt/keyrings/openvpn-as.gpg.key] http://as-repository.openvpn.net/as/debian $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/openvpn-as.list
wget --quiet -O - https://as-repository.openvpn.net/as-repo-public.gpg | sudo tee /etc/apt/keyrings/openvpn-as.gpg.key
sudo apt install apt-transport-https ca-certificates -y

sudo apt update
sudo apt install -y openvpn-as
cd /usr/local/openvpn_as/scripts
sudo ./sacli --user "openvpn" --key "prop_superuser" --value "true" UserPropPut
sudo ./sacli --user "openvpn" --key "user_auth_type" --value "local" UserPropPut
sudo ./sacli --user "openvpn" --new_pass=${admin_password} SetLocalPassword
sudo ./sacli start

sudo systemctl stop openvpnas
sleep 5
sudo systemctl start openvpnas

ip=`curl http://checkip.amazonaws.com`
private_ip=`ec2metadata --local-ipv4`
sudo apt install certbot -y
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo certbot certonly --standalone --preferred-challenges http --agree-tos --email ${email} -d ${subdomain} --non-interactive || true

sudo /usr/local/openvpn_as/scripts/sacli --key "cs.priv_key" --value_file "/etc/letsencrypt/live/${subdomain}/privkey.pem" ConfigPut || true
sudo /usr/local/openvpn_as/scripts/sacli --key "cs.cert" --value_file "/etc/letsencrypt/live/${subdomain}/cert.pem" ConfigPut || true
sudo /usr/local/openvpn_as/scripts/sacli --key "cs.ca_bundle" --value_file "/etc/letsencrypt/live/${subdomain}/chain.pem" ConfigPut || true
sudo systemctl restart openvpnas

cat << EOF > /home/ubuntu/update-ddns.py
import boto3
import argparse
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

EOF

chmod 755 /home/ubuntu/update-ddns.py

cmdline='python3 /home/ubuntu/update-ddns.py --domain ${domain} --subdomain ${subdomain}'

sudo crontab <<EOF
0 1 * * * $cmdline
@reboot $cmdline &
EOF
