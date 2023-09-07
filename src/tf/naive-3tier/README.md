## Validation of Certificates [Resolved in IaC]
1. Need to add base domain certificate. Validate it by adding to its zone.
2. Add subdomain NS value to base domain record.
3. Subdomain cert should be able to validate now.

## RDS access through jumpbox
1. Set up ssh tunnel.
    ```
    ssh -i ssh-rds.pem -f -N -L 5432:{rds-dns-name}:5432 ec2-user@{public-jumpbox-ip} -v
    ```
2. Set up pgadmin.
    - Hostname: localhost
    - port: 5432
    - username: postgres
    - password from terraform

## Force redeployment after docker push
```
aws ecs update-service --cluster api-cluster --service api-service --force-new-deployment
```
