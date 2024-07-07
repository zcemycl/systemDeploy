from dagster import asset


@asset
def asset1():
    return [1,2]
