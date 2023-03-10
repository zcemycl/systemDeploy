```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install my-kube-prometheus-stack prometheus-community/kube-prometheus-stack --version 34.10.0
kubectl get secret my-kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo # this gives grafana pwd
kubectl port-forward svc/my-kube-prometheus-stack-grafana :80 # username: admin
kubectl port-forward svc/my-kube-prometheus-stack-prometheus 9090 
```

### References
1. [How to K8s: Getting Started with Prometheus and Grafana](https://www.macstadium.com/blog/how-to-k8s-getting-started-with-prometheus-and-grafana)