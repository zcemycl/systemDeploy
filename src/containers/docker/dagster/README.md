## How to start?
1. Start service.
    ```
    mkdir -p ~/Documents/data/io_manager_storage
    docker-compose --env-file config.env up --build
    ```

## References
1. https://docs.dagster.io/deployment/dagster-instance
2. https://docs.dagster.io/concepts/code-locations/workspace-files
3. https://github.com/dagster-io/dagster/blob/1.5.1/examples/deploy_docker/docker-compose.yml
4. https://github.com/AntonFriberg/dagster-project-example
5. https://docs.dagster.io/deployment/guides/docker
