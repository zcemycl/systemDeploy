import time
from datetime import datetime

from dagster import (AssetExecutionContext, AssetKey, DagsterRunStatus,
                     DefaultSensorStatus, Definitions, OpExecutionContext,
                     RunRequest, SensorEvaluationContext, asset,
                     define_asset_job, graph_asset, job, op, run_status_sensor)


@asset
def dummy_asset(context: AssetExecutionContext):
    context.log.info("hello sleep 5")
    time.sleep(5)
    context.add_output_metadata({"abc": 4})
    return [1,2,3]



@asset
def dummy_asset2(context: AssetExecutionContext):
    context.log.info("hello sleep 2")
    time.sleep(2)
    # context.
    abc = context.get_output_metadata("abc")
    context.log.info(abc)
    return [4,6]


job_dummy = define_asset_job("job_dummy", selection=[dummy_asset])
job_dummy2 = define_asset_job("job_dummy2", selection=[dummy_asset2])

@op
def a1():
    return [1,2]

@op
def a2():
    return [3]


@run_status_sensor(
    run_status=DagsterRunStatus.SUCCESS,
    monitored_jobs=[job_dummy],
    request_job=job_dummy2,
    minimum_interval_seconds=5,
    default_status=DefaultSensorStatus.RUNNING
)
def run_job_2_sensor(context: SensorEvaluationContext):
    inst = context.instance
    mat = inst.get_latest_materialization_event(AssetKey(["dummy_asset"])).asset_materialization
    # inst.get_job_snapshot()
    context.log.info(mat)
    run_config = {
        "ops": {
            "dummy_asset2": {"config": {"dummy_asset2": context.dagster_run.job_name}}
        }
    }
    return RunRequest(run_key=f"{datetime.now().timestamp()}", run_config=run_config)

defs = Definitions(jobs=[job_dummy, job_dummy2], assets=[dummy_asset, dummy_asset2], sensors=[run_job_2_sensor])
