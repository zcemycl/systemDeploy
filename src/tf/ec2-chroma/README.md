## How to use?
1. Use curl.
```
curl --location --request GET 'https://xxxxx.execute-api.eu-west-2.amazonaws.com/v1/api/v1/heartbeat' \
--header 'x-api-key: '
```
2. Ssh into the docker container inside ec2.
```
ssh -i ssh-chroma.pem ec2-user@ip
sudo docker ps
sudo docker logs xxxx
```
3. Check out cloudwatch logs to see if apigateway is triggering.
```
API-Gateway-Execution-Logs_xxxxxxx
```
