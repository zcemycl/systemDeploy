from dagster import asset
from dagster_docker import docker_executor


@asset
def asset1():
    return [1,2]
