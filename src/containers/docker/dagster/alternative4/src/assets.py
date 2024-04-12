import io
import time
from io import StringIO
from typing import List

import pdfplumber as pp
import requests
from dagster import (AssetExecutionContext, AssetIn, AutoMaterializePolicy,
                     AutoMaterializeRule, HourlyPartitionsDefinition,
                     TimeWindowPartitionsDefinition, asset,
                     build_schedule_from_partitioned_job, define_asset_job,
                     graph_asset, op)
from pypdf import PdfReader

every_min_partition = TimeWindowPartitionsDefinition(start="2023-10-01", fmt="%Y-%m-%d", cron_schedule="*/2 * * * *")
every_hour_partition = HourlyPartitionsDefinition(start_date="2023-10-01-00:00")
wait_for_all_parents_policy = AutoMaterializePolicy.eager().with_rules(
    AutoMaterializeRule.skip_on_not_all_parents_updated(),
    AutoMaterializeRule.materialize_on_cron("*/2 * * * *", timezone="US/Central"),
)

@asset(
    key="label_pdf_asset",
    # partitions_def=every_min_partition
    partitions_def=every_hour_partition
)
def label_pdf_asset(context: AssetExecutionContext):
    """
    pdf url download
    """
    date_string = context.partition_key
    context.log.info(date_string)
    urls = [
        "https://www.fda.gov/media/176417/download?attachment"
    ]
    resp = requests.get(urls[0])
    pdf_bytes = io.BytesIO(resp.content)
    pdf_file = PdfReader(pdf_bytes)
    num_pages = len(pdf_file.pages)
    context.log.info(f"Number of pages: {num_pages}")
    text_list = []
    for page in range(num_pages):
        text = pdf_file.pages[page].extract_text()
        context.log.info(text)
        text_list.append(text)
    with pp.open(pdf_bytes) as f:
        for i in f.pages:
            print(i.extract_tables())
    return text_list

asset_job = define_asset_job(
    "asset_job", selection=[label_pdf_asset]
)
schedule = build_schedule_from_partitioned_job(
    asset_job
)

@asset(partitions_def=every_min_partition)
def a1():
    time.sleep(10)
    return [1,2,3]

@op
def plus_one(nums: List[int]):
    return [i+1 for i in nums]

@graph_asset(partitions_def=every_min_partition,
    auto_materialize_policy=wait_for_all_parents_policy
)
def a1_plus(a1):
    return plus_one(a1)

@asset(partitions_def=every_min_partition,
    auto_materialize_policy=wait_for_all_parents_policy
)
def final(a1_plus):
    all_res = []
    all_res.extend(a1_plus)
    return all_res

a1_asset_job = define_asset_job(
    "a1_asset_job", selection=[a1]
)
a1_schedule = build_schedule_from_partitioned_job(
    a1_asset_job
)

# a1_plus_asset_job = define_asset_job(
#     "a1_plus_asset_job", selection=[a1_plus]
# )
# a1_plus_schedule = build_schedule_from_partitioned_job(
#     a1_plus_asset_job
# )

# final_asset_job = define_asset_job(
#     "final_asset_job", selection=[final]
# )
# final_schedule = build_schedule_from_partitioned_job(
#     final_asset_job
# )
