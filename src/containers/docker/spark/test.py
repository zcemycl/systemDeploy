from pyspark.sql import SparkSession
from pyspark.sql.functions import col

S3_DATA_SRC_PATH = '/opt/spark-data/survey_results_public.csv'
S3_DATA_OUT_PATH = '/opt/spark-data/data-output'

def main():
    spark = SparkSession.builder.appName('leotestSpark').getOrCreate()
    all_data = spark.read.csv(S3_DATA_SRC_PATH, header=True)
    print('Total no of records in the source data: ', all_data.count())
    selected_data = all_data.where((col("Country") == "United States of America") & (col("RemoteWork") == "Fully remote"))
    print('Total no of engineers who work remotely in USA: ', selected_data.count())
    # selected_data.write.mode('overwrite').parquet(S3_DATA_OUT_PATH)
    # print('Selected data was successfully saved to local: ', S3_DATA_OUT_PATH)

if __name__ == "__main__":
    main()
