from pyspark.sql import SparkSession
from pyspark.sql import functions as f
from pyspark.sql.types import *

spark = (
    SparkSession.builder
    .config("spark.jars.packages", "org.apache.spark:spark-sql-kafka-0-10_2.12:3.1.2")
    .appName("ConsumeFromKafka")
    .getOrCreate()
)

spark.sparkContext.setLogLevel('ERROR')

df = (
    spark.readStream
    .format('kafka')
    .option("kafka.bootstrap.servers", "localhost:9092")
    .option("subscribe", "json-customers")
    .option("startingOffsets", "earliest")
    .load()
)

df.printSchema()

# schema = StructType([
#     StructField("NOME", StringType(), False),
#     StructField("SEXO", StringType(), False),
#     StructField("TELEFONE", StringType(), False),
#     StructField("NASCIMENTO", StringType(), False),
#     StructField("DT_UPDATE", StringType(), False)
# ])

schema1 = StructType([
    StructField("schema", StringType(), False),
    StructField("payload", StringType(), False)
])

schema2 = StructType([
    StructField("nome", StringType(), False),
    StructField("sexo", StringType(), False),
    StructField("telefone", StringType(), False),
    StructField("email", StringType(), False),
    StructField("foto", StringType(), False),
    StructField("nascimento", StringType(), False),
    StructField("profissao", StringType(), False),
    StructField("dt_update", LongType(), False)
])


o = df.selectExpr("CAST(value AS STRING)")

#o.writeStream.format("console").outputMode("append").option("truncate", False).start().awaitTermination()

o2 = o.select(f.from_json(f.col("value"), schema1).alias("data")).selectExpr("data.payload")
o2 = o2.selectExpr("CAST(payload AS STRING)")
novo = o2.select(f.from_json(f.col("payload"), schema2).alias("data")).selectExpr("data.*")
# #novo = df.select(from_avro(f.col("value"), jsonFormatSchema=schema).alias("data")).selectExpr("data.*")

novo.printSchema()

consulta = (
    novo
    .withColumn("dt_nascimento", f.col("nascimento"))
    .withColumn("today", f.to_date(f.current_timestamp() ) )
    .withColumn("idade", f.round(
        f.datediff(f.col("today"), f.col("dt_nascimento"))/365.25, 0)
    )
    .select('nome', 'sexo', 'email', 'profissao', 'dt_nascimento', 'today', 'idade')
    # .groupBy("sexo")
    # .agg(
    #     f.count(f.lit(1)).alias("total"),
    #     f.first("dt_nascimento").alias("first_nascimento"),
    #     f.first("today").alias("first_now"),
    #     f.round(f.avg("idade"), 2).alias("media_idade")
    # )
)

(
    consulta
    .writeStream
    .format("console")
    .outputMode("append")
    #.option("checkpointLocation", "checkpoint")
    .start()
    .awaitTermination()
)
