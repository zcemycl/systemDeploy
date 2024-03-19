from dagster import (Definitions, ScheduleDefinition, define_asset_job,
                     load_assets_from_modules)

from . import assets

all_assets = load_assets_from_modules([assets])

defs = Definitions(
    assets=all_assets,
    jobs=[
        define_asset_job(
            name="trial_dagster_job",
            selection=all_assets
        )
    ],
    schedules=[
        ScheduleDefinition(
            name="trial_dagster_schedule",
            job_name="trial_dagster_job",
            cron_schedule="* * * * *"
        )
    ]
)
