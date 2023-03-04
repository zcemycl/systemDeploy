```
helm create redis
# Delete all things in templates and values.yaml
helm install redis-release redis/
helm upgrade redis-release redis/
helm uninstall redis-release
```