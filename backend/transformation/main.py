from service.s3_connection import S3Connection, S3Settings
from service import Service


def main():
    s3_settings = S3Settings(
        raw_bucket='cloud-etl-pokeapi-raw-data',
        processed_bucket='cloud-etl-pokeapi-processed-data',
        raw_key='pikachu_20251112093305.json',
        processed_key="charizard_20251113110707_processed.json"
    )

    # service = Service()
    # service.s3_settings = s3_settings
    # service.run()

    conn = S3Connection(settings=s3_settings)
    # response = conn.read_from_raw_bucket()
    response = conn.read_from_processed_bucket()
    print(response)


if __name__ == "__main__":
    main()

