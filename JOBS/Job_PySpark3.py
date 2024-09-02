import sys
import json
import pyspark
from pyspark.sql.functions import col, count, struct, collect_list
from pyspark.sql import SparkSession
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame



# Leggi i parametri dal job
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

# Inizializza il contesto Spark e Glue
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Carica i dati dai file CSV su S3
tags_dataset_path = "s3://tedx-2024-colo-data/tags.csv"
tedx_dataset_path = "s3://tedx-2024-colo-data/final_list.csv"
tags_dataset = spark.read.option("header", "true").csv(tags_dataset_path)
tedx_dataset = spark.read.option("header", "true").csv(tedx_dataset_path)

# Carica i dati sui trend di ricerca
# Assumiamo che tu abbia già eseguito lo script Python con Pytrends e salvato i dati su S3
trends_dataset_path = "s3://tedx-2024-colo-data/trends.csv"
trends_dataset = spark.read.option("header", "true").csv(trends_dataset_path)

# Unisci i dati dei TEDx Talks con i dati sui trend
tag_video_info = tags_dataset.join(tedx_dataset, tags_dataset.id == tedx_dataset.id, "left") \
    .select(tags_dataset["tag"], tedx_dataset["id"].alias("video_id"), tedx_dataset["title"].alias("video_title"))

# Raggruppa per tag e crea una struttura dati
tag_info = tag_video_info.groupBy("tag") \
    .agg(count("*").alias("tag_count"), collect_list(struct(col("video_id"), col("video_title"))).alias("videos"))

# Unisci i dati sui trend con i dati TEDx
tedx_with_trends = tedx_dataset.join(trends_dataset, tedx_dataset.title == trends_dataset.keyword, "left") \
    .select(tedx_dataset["id"], tedx_dataset["title"], tedx_dataset["description"], trends_dataset["interest"])

# Converti i DataFrame in DynamicFrame
tag_info_dynamic_frame = DynamicFrame.fromDF(tag_info, glueContext, "tag_info_dynamic_frame")
tedx_with_trends_dynamic_frame = DynamicFrame.fromDF(tedx_with_trends, glueContext, "tedx_with_trends_dynamic_frame")

# Opzioni per la scrittura nel database MongoDB
write_mongo_options = {
    "connectionName": "TEDX",
    "database": "unibg_tedx_2024",
    "collection": "tedx_tag_Trends",
    "ssl": "true",
    "ssl.domain_match": "false"
}

# Scrivi i DynamicFrame nel database MongoDB
glueContext.write_dynamic_frame.from_options(
    tag_info_dynamic_frame,
    connection_type="mongodb",
    connection_options=write_mongo_options
)

glueContext.write_dynamic_frame.from_options(
    tedx_with_trends_dynamic_frame,
    connection_type="mongodb",
    connection_options=write_mongo_options
)

# Completa il job
job.commit()
