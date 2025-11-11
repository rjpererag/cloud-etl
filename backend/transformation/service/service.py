from .transform import TransformLayer
from .s3_connection import S3Connection
from .settings import *

class Service:
    def __init__(self):
        self.transformer_settings = TransformSettings()
        self.s3_settings = S3Settings()
        self.transformer = TransformLayer(settings=self.transformer_settings)
        self.s3_connection = S3Connection(settings=self.s3_settings)

    def run(self):
        try:
            print("S3 Settings:")
            print(self.s3_settings)

            print("Transformer Settings:")
            print(self.transformer_settings)

            print("Reading from S3")
            raw_data = self.s3_connection.read_from_raw_bucket()

            print("Transforming data")
            data_transformed = self.transformer.transform(data=raw_data)

            print("Loading to processed layer")
            self.s3_connection.write_to_processed_bucket(data=data_transformed)
        except Exception as e:
            print(f"Failed during processing: {str(e)}")