## How to start?
1. Download `docker-compose.yml` file.
    ```
    curl -LfO 'https://airflow.apache.org/docs/apache-airflow/2.7.1/docker-compose.yaml'
    mkdir -p ./dags ./logs ./plugins ./config
    echo -e "AIRFLOW_UID=$(id -u)" > .env
    docker compose up airflow-init
    docker compose up -d
    ```

## References
1. https://xnuinside.medium.com/quick-guide-how-to-run-apache-airflow-cluster-in-docker-compose-615eb8abd67a
2. https://towardsdatascience.com/setting-up-apache-airflow-with-docker-compose-in-5-minutes-56a1110f4122
3. https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html
4. https://medium.com/@ericfflynn/my-journey-with-apache-airflow-d7d364fc84ba
5. https://levelup.gitconnected.com/running-apache-airflow-via-docker-compose-bcbb19f30cd6
