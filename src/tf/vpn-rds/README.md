## Setup
- Run the followings to set up local and cloud.
```bash
git clone https://github.com/OpenVPN/easy-rsa.git
cd easy-rsa/easyrsa3
./easyrsa init-pki
./easyrsa build-ca  # add your passphrase
./easyrsa build-server-full server nopass
./easyrsa build-client-full client1.domain.tld nopass
mkdir ~/my-vpn-files/
cp pki/ca.crt ~/my-vpn-files/
cp pki/issued/server.crt ~/my-vpn-files/
cp pki/private/server.key ~/my-vpn-files/
cp pki/issued/client1.domain.tld.crt ~/my-vpn-files
cp pki/private/client1.domain.tld.key ~/my-vpn-files/
cd ~/my-vpn-files/
terraform init
terraform apply -auto-approve
```
- AWS Console > VPN Endpoint > download client configuration > `downloaded-client-config.ovpn`
- In downloaded-client-config.ovpn, above `reneg-sec 0` and below `</ca>`, insert followings...
```
<cert>
...from client1.domain.tld.cert wrapped
around -----BEGIN CERTIFICATE-----
and -----END CERTIFICATE-----
</cert>

<key>
...from client1.domain.tld.key wrapped
around -----BEGIN PRIVATE KEY-----
and -----END PRIVATE KEY-----
</key>
```
- Import `downloaded-client-config.ovpn` to openvpn client.

## SSH Connection to private instance
- ssh via private ip address.
```
ssh -i ssh-rds.pem ec2-user@{private-ip}
```

## Connection to RDS instance
- Need to ssh into the private instance and check private ip of rds.
    ```
    dig {dns_name_rds}
    ```
- Connect with that private ip address with vpn on.

## Connection to RDS hostname !!!
- In `vpn-client`, you don't need private ip address!!! Just need private hostname!!!
- Difference is adding dns_servers in ec2-vpn-client-endpoint!!!


## References
1. https://spak.no/blog/article/63f519260faeadeeeb968af2
2. https://www.youtube.com/watch?v=Bv70DoHDDCY
3. https://aws.amazon.com/blogs/database/accessing-an-amazon-rds-instance-remotely-using-aws-client-vpn/#:~:text=AWS%20Client%20VPN%20can%20provide,to%20your%20resources%20on%20AWS.
