import os
import struct

from pyspark.sql import SparkSession
from pyspark.sql.types import StructType,StructField,FloatType,IntegerType,StringType,TimestampType
from pyspark.sql.functions import from_json,col, to_json
from struct import Struct

def writeToKafka(writeDF, _):
    writeDF.write \
                .format("kafka")\
                .option("kafka.bootstrap.servers", "172.17.0.1:9092") \
                .option("topic", "sales-transactions-2") \
                .save()

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
        .config("spark.jars", os.getcwd() + "/jars/spark-sql-kafka-0-10_2.12-3.0.0.jar" + "," + 
                              os.getcwd() + "/jars/kafka-clients-3.0.0.jar" + "," +
                              os.getcwd() + "/jars/spark-streaming-kafka-0-10_2.12-3.0.0.jar" + "," +
                              os.getcwd() + "/jars/commons-pool2-2.8.0.jar" + "," +
                              os.getcwd() + "/jars/spark-token-provider-kafka-0-10_2.12-3.0.0.jar") \
        .getOrCreate()

spark.sparkContext.setLogLevel("ERROR")

df = spark \
        .readStream \
        .format("kafka") \
        .option("kafka.bootstrap.servers", "172.17.0.1:9092") \
        .option("subscribe", "sales-transactions") \
        .option("startingOffsets", "earliest") \
        .load() 

df1 = df.select(from_json(col("value").cast("string"),transactionSchema).alias("value"))

df_exp = df1.select("value.transactionId", 
                    "value.productId", 
                    "value.productName", 
                    "value.productCategory", 
                    "value.productPrice", 
                    "value.productQuantity", 
                    "value.productBrand", 
                    "value.currency",
                    "value.customerId",
                    "value.transactionDate",
                    "value.paymentMethod")

df_exp.printSchema()

#.foreachBatch(writeToKafka) \

df_exp.writeStream \
        .format("json") \
        .queryName("Q Name") \
        .outputMode("append") \
        .option("path", "output") \
        .option("checkpointLocation", "chk-point-dir") \
        .trigger(processingTime="5 second") \
        .start()\
        .awaitTermination()

df_exp.show()

