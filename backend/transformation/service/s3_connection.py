# backend/transformation/main.py (Inside the container)

from .settings import S3Settings
import boto3
import json

class S3Connection:

    def __init__(self, settings: S3Settings = S3Settings()):
        self.settings = settings
        self.client = boto3.client('s3')

    def read_from_processed_bucket(self) -> dict | list[dict]:
        try:
            response = self.client.get_object(
                Bucket=self.settings.processed_bucket, Key=self.settings.processed_key
            )
            s3_data_bytes = response['Body'].read()
            s3_data = s3_data_bytes.decode('utf-8')
            print("----------------------------------------------------------------------")
            print(s3_data)
            print("----------------------------------------------------------------------")
            return json.loads(s3_data)

        except Exception as e:
            print(f"Failed to read from S3: {e}")
            exit(1)

    def read_from_raw_bucket(self) -> dict | list[dict]:
        try:
            response = self.client.get_object(
                Bucket=self.settings.raw_bucket, Key=self.settings.raw_key
            )
            print(response)
            s3_data_bytes = response['Body'].read()
            s3_data_string = s3_data_bytes.decode('utf-8')
            print("----------------------------------------------------------------------")
            print(s3_data_string)
            print("----------------------------------------------------------------------")
            raw_data = json.loads(s3_data_string)
            raw_data["data"] = json.loads(raw_data["data"])
            print(f"Successfully read {len(raw_data)} bytes of raw data.")
            return raw_data

        except Exception as e:
            print(f"Failed to read from S3: {e}")
            exit(1)

    def write_to_processed_bucket(self, data, key: str) -> None:
        self.client.put_object(
            Bucket=self.settings.processed_bucket,
            Key=key,
            Body=json.dumps(data, indent=4)
        )
        print(f"Data loading completed. Data saved to: s3://{self.settings.processed_bucket}/{key}")
        print("Fargate task complete.")
