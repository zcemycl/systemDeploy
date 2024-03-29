## How to start?
1. Start service. `docker compose up`
2. Visit minio portal in `127.0.0.1:9001` with creds listed in `docker-compose.yml` file.
3. Generate Access Key in portal. (Optional: default access key is your username and password)
4. Use `aws-vault` to store the new cred for minio to mimic `aws configure`.
5. Create bucket and upload artefact to minic the operation.
6. Run the following commands to test `aws-cli`.
    ```
    aws-vault exec minio-test --no-session -- aws --endpoint-url http://localhost:9000 s3 ls
    aws-vault exec minio-test --no-session -- aws --endpoint-url http://localhost:9000 s3 ls s3://random
    ```


## References
1. https://min.io/docs/minio/linux/integrations/aws-cli-with-minio.html
2. https://sanidhya235.medium.com/introduction-to-minio-193e8523a4a8
