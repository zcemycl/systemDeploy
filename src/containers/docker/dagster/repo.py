from assets import hackernews_top_stories, topstory_ids
from dagster import FilesystemIOManager, asset, graph, op, repository, schedule
from dagster_docker import docker_executor


@op
def hello():
    return 1


@op
def goodbye(foo):
    if foo != 1:
        raise Exception("Bad io manager")
    return foo * 2


@graph
def my_graph():
    goodbye(hello())

@asset
def new_asset():
    return [1,2,3]


my_job = my_graph.to_job(name="my_job")

my_step_isolated_job = my_graph.to_job(
    name="my_step_isolated_job",
    executor_def=docker_executor,
    resource_defs={
        "io_manager": FilesystemIOManager(base_dir="/tmp/io_manager_storage")
    },
)


@schedule(cron_schedule="* * * * *", job=my_job, execution_timezone="US/Central")
def my_schedule(_context):
    return {}


@repository
def deploy_docker_repository():
    return [
        my_job,
        my_step_isolated_job,
        my_schedule,
        topstory_ids,
        hackernews_top_stories,
        new_asset
    ]
