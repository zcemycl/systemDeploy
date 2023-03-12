1. Run locally. 
    ```
    uvicorn app.main:app --host 0.0.0.0 --port 8888
    ```
2. Run app in docker. 
    ```
    docker build -t fpg:latest .
    docker run -d -p 8888:8888 fpg:latest # Visit localhost:8888 or /docs
    docker rm id -f
    ```
3. Run fastapi prometheus and grafana setup.
    ```
    docker-compose up -d
    docker-compose down
    ```
4. Terminal runs some workloads.
    ```
    watch -n 1 "curl localhost:8888/"
    ```
5. Prometheus localhost:9090, navigate to graph. 
    ```
    rate(http_requests_total{job="app", handler="/"}[5m])
    ```
6. Grafana localhost:3000, navigate to Settings -> DataSources -> Prometheus (http://prometheus:9090).
    ```
    rate(http_requests_total{job="app", handler="/"}[5m])
    Options: Auto Legend, 30s Min step, Time series format, Both Types, Enable Exemplars
    ```