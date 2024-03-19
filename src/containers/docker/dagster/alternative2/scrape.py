from dagster import asset


@asset
def dummy_asset():
    return [1,2,3]
