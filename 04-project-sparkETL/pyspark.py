from awsglue.utils import getResolvedOptions
import sys
from pyspark import SparkConf, SparkContext
from pyspark.sql import SparkSession
from operator import add
from pyspark.sql.functions import col, regexp_extract, max
from pyspark.sql.types import *

conf = SparkConf().setAppName("Spark RDD")
sc = SparkContext.getOrCreate(conf=conf)
spark = SparkSession.builder.appName("Spark DataFrame").getOrCreate()

args = getResolvedOptions(sys.argv,['s3_target_path_key','s3_target_path_bucket'])
bucket = args['s3_target_path_bucket']
fileName = args['s3_target_path_key']

inputFilePath = f"s3a://{bucket}/{fileName}"
finalFilePath = "s3a://pyspark-compressed-juiceb/Entities"

print(bucket, fileName)

schema = StructType([ StructField('rawEntities', StringType()),  StructField('Count' , IntegerType())])

rdd = sc.textFile(inputFilePath)
rdd = rdd.flatMap(lambda x: x.split(" ")).map(lambda x : (x.split(" ")[0], 1)).reduceByKey(add)
df = spark.createDataFrame(data=rdd, schema = schema)
df = df.withColumn("Entities", regexp_extract(col("rawEntities"),'[^!".?@:,\'*…_()-|‘&♡—ㅡ’]+',0))
df = df.filter(col("Entities") != "")
df = df.select("Entities","Count").groupBy("Entities").agg(max("Count").alias("Count"))
df.write.mode("append").parquet(finalFilePath)

# DataFrame to DynamicFrame
# 이 때는 s3 경로 "s3a:", "s3:" 둘 다 가능

# from awsglue.context import GlueContext
# from awsglue.dynamicframe import DynamicFrame

# glue_context = GlueContext(sc)

# dynamic_frame_write = DynamicFrame.fromDF(df, glue_context, "dynamic_frame_write")

# glue_context.write_dynamic_frame.from_options(
#     frame=dynamic_frame_write,
#     connection_type="s3",
#     connection_options= {
#         "path": finalFilePath,
#     },
#     format="parquet"
# )
