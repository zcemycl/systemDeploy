#!/bin/bash
targetbash=/etc/profile.d/jupyter-env.sh
touch $targetbash
echo "export CONTAINER_IMAGE_URI=${container_image_uri}" >> $targetbash
echo "export SCRIPT_S3_BUCKET=${script_s3_bucket}" >> $targetbash
echo "export SAGEMAKER_ROLE_ARN=${sagemaker_role_arn}" >> $targetbash

CURR_VERSION=$(cat /etc/os-release)
if [[ $CURR_VERSION == *$"http://aws.amazon.com/amazon-linux-ami/"* ]]; then
	sudo initctl restart jupyter-server --no-wait
else
	sudo systemctl --no-block restart jupyter-server.service
fi
