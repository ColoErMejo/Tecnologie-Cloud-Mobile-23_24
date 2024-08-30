###### TEDx-Load-Aggregate-Model
######

import sys
import json
import pyspark
from pyspark.sql.functions import col, collect_list, array_join

from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql.functions import col, count, struct


###### READ PARAMETERS
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

##### START JOB CONTEXT AND JOB
sc = SparkContext()


glueContext = GlueContext(sc)
spark = glueContext.spark_session
    
job = Job(glueContext)
job.init(args['JOB_NAME'], args)


# Leggi il dataset dei tag
tags_dataset_path = "s3://tedx-2024-colo-data/tags.csv"
tags_dataset = spark.read.option("header", "true").csv(tags_dataset_path)

# Calcola frequenza tag
tag_counts = tags_dataset.groupBy("tag").agg(count("*").alias("tag_count"))

# Ordina tag: frequenza decrescente
tag_counts = tag_counts.orderBy(col("tag_count").desc())

# Risultati
tag_counts.show()


# Esegui una join tra i tag più frequenti e il dataset originale dei tag per ottenere tutte le informazioni
top_tags_info = tag_counts.join(tags_dataset, "tag", "left")

# Mostra i risultati con tutte le informazioni
top_tags_info.show()
#---------------
# Converte il DataFrame Spark in un DynamicFrame
tag_counts_dynamic_frame = DynamicFrame.fromDF(tag_counts, glueContext, "tag_counts_dynamic_frame")

# Opzioni per la scrittura nel database MongoDB
write_mongo_options = {
    "connectionName": "TEDX",
    "database": "unibg_tedx_2024",
    "collection": "tedx_tag_counts",
    "ssl": "true",
    "ssl.domain_match": "false"}

# Scrivi il DynamicFrame nel database MongoDB
glueContext.write_dynamic_frame.from_options(
    tag_counts_dynamic_frame,
    connection_type="mongodb",
    connection_options=write_mongo_options
)
#---------------

