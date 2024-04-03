import io
from io import StringIO
from typing import List

import pdfplumber as pp
import requests
from dagster import (AssetExecutionContext, AssetIn,
                     HourlyPartitionsDefinition,
                     TimeWindowPartitionsDefinition, asset,
                     build_schedule_from_partitioned_job, define_asset_job)
from pypdf import PdfReader


@asset(
    key="label_pdf_asset",
    partitions_def=TimeWindowPartitionsDefinition(start="2023-10-01", fmt="%Y-%m-%d", cron_schedule="*/2 * * * *")
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
