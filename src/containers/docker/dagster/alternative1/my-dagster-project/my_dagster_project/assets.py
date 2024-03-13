import json

import requests
from dagster import asset


@asset
def stanford_uni_() -> None:
    url = "https://api.openalex.org/institutions?search=stanford"
    stanford = requests.get(url).json()

    print(stanford)
