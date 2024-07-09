from dagster import AssetExecutionContext, Definitions, asset, define_asset_job
from dagster_aws.s3 import S3PickleIOManager, S3Resource


@asset
def asset1():
    return [1,2]

@asset
def asset2(context: AssetExecutionContext, s3: S3Resource):
    objs = s3.get_client().list_objects_v2(
        Bucket='my-bucket',
        Prefix='some-key'
    )
    context.log.info(objs)
    return [3,4]

# jobs = define_asset_job("all_assets", selection=[asset1,asset2])

default_s3_resource = S3Resource(
    region_name="eu-west-2",
    endpoint_url="http://dagster-s3:9000",
    aws_secret_access_key="minioadmin",
    aws_access_key_id="minioadmin"
    )

defs = Definitions(
    assets=[asset1, asset2],
    # jobs=[jobs],
    resources={
        "s3": default_s3_resource,
        "io_manager": S3PickleIOManager(
            s3_resource=default_s3_resource,
            s3_bucket="my-bucket"
        )
    }
)
