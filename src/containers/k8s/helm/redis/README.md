### How to run?
1. Create encoded secrets and append them to `secret.yml`. (Try not to push)
```
# encode
echo -n 'xxxx' | base64
# decode
echo -n 'xxxx' | base64 --decode
```
2. Apply the helm chart.
```
helm create redis
# Delete all things in templates and values.yaml
helm install redis-release redis/
helm upgrade redis-release redis/
helm upgrade --install redis-release redis/
helm uninstall redis-release
```

### References
1. [How to Create Helm Charts - The Ultimate Guide](https://www.youtube.com/watch?v=jUYNS90nq8U)