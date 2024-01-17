```
# Create fake model compression file .tar.gz
tar -czvf outputs/model.tar.gz src/lambda-invoke # src folder will include
# Create docker image
cd src/dummy-model
docker build --platform linux/amd64 -t test-dummy-sagemaker-image .
# Run terraform
terraform init
terraform apply -auto-approve
```

### Notes
1. When specifying model data s3 location, sagemaker will auto download, untar and put them into `/opt/ml/model`.

### References
1. https://www.cyberciti.biz/faq/how-to-create-tar-gz-file-in-linux-using-command-line/
2. https://medium.com/@adrienchuttarsing/how-to-deploy-a-personalized-model-container-on-aws-sagemaker-with-docker-and-flask-e8e2ba1833bd
3. https://towardsdatascience.com/deploy-a-custom-ml-model-as-a-sagemaker-endpoint-6d2540226428
4. https://github.com/aws/amazon-sagemaker-examples/blob/main/advanced_functionality/multi_model_bring_your_own/container/Dockerfile
5. https://towardsdatascience.com/deploying-sagemaker-endpoints-with-terraform-3b09fb3e1d59
