import os

from pyspark.sql import SparkSession # type: ignore
from pyspark.sql.types import StructType,StructField,FloatType,IntegerType,StringType,TimestampType # type: ignore
from pyspark.sql.functions import from_json,col, to_json # type: ignore
from struct import Struct

#Cria a sessão do Spark
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

#Informa o nivel de log
spark.sparkContext.setLogLevel("INFO")

#Conecta-se com o Kafka de Origem
source_data = spark \
        .readStream \
        .format("kafka") \
        .option("kafka.bootstrap.servers", "172.17.0.1:9092") \
        .option("subscribe", "sales-transactions") \
        .option("startingOffsets", "earliest") \
        .load() 
source_data.printSchema()

#Cria uma struct
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

#Converte o binário em JSON
source_data = source_data.selectExpr("CAST(value AS STRING)").select(from_json(col("value"),transactionSchema).alias("data")).select("data.*")
source_data.printSchema()

#Transformar os dados....
transformed_data = source_data.withColumn("totalAmount", col('productPrice') * col('productQuantity'))
transformed_data.printSchema()

#Envia para o Kafka de Destino
transformed_data.selectExpr("to_json(struct(*)) AS value") \
    .writeStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "172.17.0.1:9093") \
    .option("topic", "transformed-transactions") \
    .option("checkpointLocation", "chk-point-dir") \
    .start().awaitTermination()