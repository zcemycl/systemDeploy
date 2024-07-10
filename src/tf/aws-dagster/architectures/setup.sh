#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

sudo sed -i "/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf
sudo apt-get update
sudo apt-get upgrade -q -y | tee -a
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
