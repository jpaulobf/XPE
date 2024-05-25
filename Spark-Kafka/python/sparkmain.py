import os

from pyspark.sql import SparkSession
from pyspark.sql.types import StructType,StructField,FloatType,IntegerType,StringType,TimestampType
from pyspark.sql.functions import from_json,col

transactionSchema = StructType([
                        StructField("transactionId",StringType(),False),
                        StructField("productId",StringType(),False),
                        StructField("productName",StringType(),False),
                        StructField("productCategory",StringType(),False),
                        StructField("productPrice",FloatType(),False),
                        StructField("productQuantity",IntegerType(),False),
                        StructField("productBrand",StringType(),False),
                        StructField("currency",StringType(),False),
                        StructField("customerId",StringType(),False),
                        StructField("transactionDate",TimestampType(),False),
                        StructField("paymentMethod",StringType(),False)
                        ])

spark = SparkSession \
        .builder \
        .appName("SparkStructuredStreaming") \
        .master("local") \
        .config("spark.streaming.stopGracefullyOnShutdown", "true")\
        .config("spark.driver.host", "localhost")\
        .config("spark.jars", os.getcwd() + "/jars/spark-sql-kafka-0-10_2.12-3.0.0.jar"+ "," + os.getcwd() + "/jars/kafka-clients-3.0.0.jar") \
        .getOrCreate()


spark.sparkContext.setLogLevel("ERROR")

df = spark \
        .readStream \
        .format("kafka") \
        .option("kafka.bootstrap.servers", "172.17.0.1:9092") \
        .option("subscribe", "sales-transactions") \
        .option("startingOffsets", "earliest") \
        .load() 

df.printSchema()
df1 = df.select(from_json(col("value").cast("string"),transactionSchema).alias("data"))
df1.printSchema()

df_exp = df1.select("data.transactionId", "data.productId")
df_exp.printSchema()

