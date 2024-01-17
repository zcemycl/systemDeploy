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
