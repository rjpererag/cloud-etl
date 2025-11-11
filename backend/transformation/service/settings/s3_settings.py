import os
from dataclasses import dataclass

@dataclass
class S3Settings:
    raw_bucket: str = os.environ.get('RAW_BUCKET')
    processed_bucket: str = os.environ.get('PROCESSED_BUCKET')
    raw_key: str = os.environ.get('S3_RAW_KEY')