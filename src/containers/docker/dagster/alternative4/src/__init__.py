from dagster import (Definitions, ScheduleDefinition, define_asset_job,
                     load_assets_from_modules)

from . import assets

all_assets = load_assets_from_modules([assets])

defs = Definitions(
    assets=all_assets,
    # jobs=[assets.asset_job],
    schedules=[assets.schedule]
    )
