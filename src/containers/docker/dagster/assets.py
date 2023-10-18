import json

import pandas as pd
import requests
from dagster import AssetExecutionContext, MetadataValue, asset


@asset  # add the asset decorator to tell Dagster this is an asset
def topstory_ids() -> None:
    newstories_url = "https://hacker-news.firebaseio.com/v0/topstories.json"
    top_new_story_ids = requests.get(newstories_url).json()[:100]

    # os.makedirs("data", exist_ok=True)
    with open("/tmp/io_manager_storage/topstory_ids.json", "w") as f:
        json.dump(top_new_story_ids, f)


# asset dependencies can be inferred from parameter names
@asset(deps=[topstory_ids])
def hackernews_top_stories(context: AssetExecutionContext):
    """Get items based on story ids from the HackerNews items endpoint."""
    with open("/tmp/io_manager_storage/topstory_ids.json", "r") as f:
        hackernews_top_story_ids = json.load(f)

    results = []
    for item_id in hackernews_top_story_ids:
        item = requests.get(
            f"https://hacker-news.firebaseio.com/v0/item/{item_id}.json"
        ).json()
        results.append(item)

    df = pd.DataFrame(results)
    df.to_csv("/tmp/io_manager_storage/hackernews_top_stories.csv")

    # recorded metadata can be customized
    metadata = {
        "num_records": len(df),
        "preview": MetadataValue.md(df[["title", "by", "url"]].to_markdown()),
    }

    context.add_output_metadata(metadata=metadata)
