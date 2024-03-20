import io
from io import StringIO
from typing import List

import pdfplumber as pp
import requests
from dagster import AssetExecutionContext, AssetIn, asset
from pypdf import PdfReader


@asset(key="label_pdf_asset")
def label_pdf_asset(context: AssetExecutionContext):
    """
    pdf url download
    """
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

@asset(ins={"upstream": AssetIn(key="label_pdf_asset")})
def save_text_to_df(context: AssetExecutionContext, upstream: List):
    """
    save pdf text to dataframe
    """
    pass
