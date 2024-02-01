import os
import time

from sagemaker.estimator import Estimator

container_image_uri = os.environ["container_image_uri"]
script_s3_bucket = os.environ['script_s3_bucket']
sagemaker_role_arn = os.environ['sagemaker_role_arn']

def lambda_handler(event, context):
    start_time = time.time()
    est = Estimator(
        container_image_uri,
        sagemaker_role_arn,
        train_instance_count=1,
        # train_instance_type="local",  # use local mode
        train_instance_type="ml.c5.xlarge",
        base_job_name=f"leo-try-training-{int(time.time())}",
    )
    est.set_hyperparameters(epochs=10)
    est.fit(f"s3://{script_s3_bucket}/data", wait=False)
    end_time = time.time()
    print(f"Training job initialisation takes: {(end_time-start_time)/60} min")
