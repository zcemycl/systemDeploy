from dagster import asset


@asset
def asset1():
    return [1,2]

@asset
def asset2():
    return [3,4]
