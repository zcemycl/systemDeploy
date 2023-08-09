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

### References
1. [FastAPI Microservice with Docker, Prometheus and Grafana.](https://www.youtube.com/watch?v=A6K0ZXUKgYg)
2. [https://github.com/vegasbrianc/prometheus](https://github.com/vegasbrianc/prometheus)
3. [Testing Application Monitoring Locally with a Docker Composition](https://dev.to/camptocamp-ops/testing-application-monitoring-locally-with-a-docker-composition-47hn)
4. [Prometheus Query Examples](https://prometheus.io/docs/prometheus/latest/querying/examples/)
5. [https://github.com/marcel-dempers/docker-development-youtube-series](https://github.com/marcel-dempers/docker-development-youtube-series)
6. [https://github.com/trallnag/prometheus-fastapi-instrumentator#exposing-endpoint](https://github.com/trallnag/prometheus-fastapi-instrumentator#exposing-endpoint)
