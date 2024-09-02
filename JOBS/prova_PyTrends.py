import pandas as pd
from pytrends.request import TrendReq
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

# Funzione per ottenere i dati di Google Trends
def fetch_trends(keywords):
    pytrends = TrendReq(hl='en-US', tz=360)
    pytrends.build_payload(keywords, cat=0, timeframe='today 12-m', geo='', gprop='')
    trends = pytrends.interest_over_time()
    return trends.reset_index()

# Funzione per caricare il file su S3
def upload_to_s3(file_path, bucket_name, s3_file_path):
    s3 = boto3.client('s3')
    try:
        s3.upload_file(file_path, bucket_name, s3_file_path)
        print(f'Successfully uploaded {file_path} to s3://{bucket_name}/{s3_file_path}')
    except FileNotFoundError:
        print(f'The file {file_path} was not found')
    except NoCredentialsError:
        print('Credentials not available')
    except PartialCredentialsError:
        print('Incomplete credentials provided')
    except Exception as e:
        print(f'An error occurred: {e}')

# Esegui la raccolta dei dati sui trend
keywords = ['TEDx', 'Motivation', 'Innovation']  # Termini di ricerca
trends_df = fetch_trends(keywords)

# Salva il DataFrame in un file CSV
local_file_path = 'trends.csv'
trends_df.to_csv(local_file_path, index=False)

# Parametri per il bucket S3
bucket_name = 'tedx-2024-colo-data'  # Nome del tuo bucket S3
s3_file_path = 's3://tedx-2024-colo-data/trends.csv'  # Percorso nel bucket S3

# Carica il file CSV su S3
upload_to_s3(local_file_path, bucket_name, s3_file_path)
