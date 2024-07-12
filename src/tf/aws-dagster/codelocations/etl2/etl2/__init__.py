import os

from dagster import AssetExecutionContext, Definitions, asset, define_asset_job
from dagster_aws.s3 import S3PickleIOManager, S3Resource

ENV = os.getenv("ENV", "local")
match ENV:
    case "dev":
        bucket_name = "aws-dagster-storage"
        default_s3_resource = S3Resource(region_name="eu-west-2")
    case _:
        bucket_name = "my-bucket"
        default_s3_resource = S3Resource(
            region_name="eu-west-2",
            endpoint_url="http://dagster-s3:9000",
            aws_secret_access_key="minioadmin",
            aws_access_key_id="minioadmin",
        )


@asset
def asset3():
    return [1, 2]


defs = Definitions(
    assets=[asset3],
    # jobs=[jobs],
    resources={
        "s3": default_s3_resource,
        "io_manager": S3PickleIOManager(
            s3_resource=default_s3_resource, s3_bucket=bucket_name
        ),
    },
)
