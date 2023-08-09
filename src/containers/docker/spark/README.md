```
docker build -t cluster-apache-spark:latest .
docker-compose up -d
mkdir /tmp/data
mkdir /tmp/apps
cp *.csv /tmp/data
cp *.py /tmp/apps
mkdir /tmp/data/data-output
docker exec -it spark-spark-master-1 bash
bin/spark-submit /opt/spark-apps/test.py
OR
docker exec -it spark-spark-master-1 bash -c "bin/spark-submit /opt/spark-apps/test.py"
```

## Add history
```
docker exec -it spark-spark-master-1 bash -c "mkdir /tmp/spark-events"
sbin/start-history-server.sh
```

### References
1. [Create Apache Spark Docker Container using Docker-Compose](https://cloudinfrastructureservices.co.uk/create-apache-spark-docker-container-using-docker-compose/)
2. [PySpark: org.apache.spark.sql.AnalysisException: Attribute name ... contains invalid character(s) among " ,;{}()\n\t=". Please use alias to rename it](https://stackoverflow.com/questions/45804534/pyspark-org-apache-spark-sql-analysisexception-attribute-name-contains-inv)
