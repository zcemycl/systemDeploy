from pyspark import SparkContext
from pyspark.sql import SparkSession
from pyspark.sql.functions import col

S3_DATA_SRC_PATH = '/opt/spark-data/survey_results_public.csv'
S3_DATA_OUT_PATH = '/opt/spark-data/data-output'

def main():
    spark = SparkSession.builder.appName('leotestSpark').getOrCreate()
    sc = spark.sparkContext
    log4jLogger = sc._jvm.org.apache.log4j
    LOGGER = log4jLogger.LogManager.getLogger(__name__)
    all_data = spark.read.csv(S3_DATA_SRC_PATH, header=True)
    logstat1 = f'Total no of records in the source data: {all_data.count()}'
    print(logstat1)
    LOGGER.info(logstat1)
    selected_data = all_data.where((col("Country") == "United States of America") & (col("RemoteWork") == "Fully remote"))
    logstat2 = f'Total no of engineers who work remotely in USA: {selected_data.count()}'
    print(logstat2)
    LOGGER.info(logstat2)
    for col_name in selected_data.columns:
        selected_data = selected_data.withColumnRenamed(col_name, col_name.replace(" ",""))
    # selected_data.write.mode('overwrite').parquet(S3_DATA_OUT_PATH)
    # logstat3 = f'Selected data was successfully saved to local: {S3_DATA_OUT_PATH}'
    # print(logstat3)
    # LOGGER.info(logstat3)
    # # sc.close()
    # spark.stop()

if __name__ == "__main__":
    main()
