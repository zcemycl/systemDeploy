```
docker build -t cluster-apache-spark:3.0.2 .
docker-compose up -d
cp *.csv /tmp/data
cp *.py /tmp/apps
mkdir /tmp/data/data-output
docker exec -it spark-spark-master-1 bash
bin/spark-submit /opt/spark-apps/test.py 
```