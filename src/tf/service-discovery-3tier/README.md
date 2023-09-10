## VPN access
1. Turn on VPN client.
2. Access the backend api through service discovery.
    ```bash
    curl http://test.service.internal:3000/
    ```
3. Access the db through service discovery (dns resolver requires vpn on to deploy?)
    ```
    db.service.internal
    port: 5432
    ```

## References
1. https://medium.com/inspiredbrilliance/ecs-integrated-service-discovery-18cdbce45d8b
2. https://mikemather.cintsa-cms.com/posts/aws-cloud-map-service-discovery-for-ecs-fargate-containers/
3. https://aws.amazon.com/blogs/aws/amazon-ecs-service-discovery/
4.
