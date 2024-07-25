import asyncio
import json
import os

from openfga_sdk.client import ClientConfiguration, OpenFgaClient


async def main():
    configuration = ClientConfiguration(
        api_url = os.environ.get('FGA_API_URL'), # required, e.g. https://api.fga.example
        store_id = os.environ.get('FGA_STORE_ID'), # optional, not needed for `CreateStore` and `ListStores`, required before calling for all other methods
        authorization_model_id = os.environ.get('FGA_MODEL_ID'), # Optional, can be overridden per request
    )

    # Enter a context with an instance of the OpenFgaClient
    async with OpenFgaClient(configuration) as fga_client:
        api_response = await fga_client.read_authorization_models()
        await fga_client.close()

asyncio.run(main())
