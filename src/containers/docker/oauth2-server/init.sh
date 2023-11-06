#!/bin/bash
curl --location 'http://localhost:8002/default_issuer/token' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode 'client_id=fake' \
--data-urlencode 'client_secret=fake' \
--data-urlencode 'mock_type=user'
