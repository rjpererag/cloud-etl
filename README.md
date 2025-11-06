# cloud-etl
A very basic ETL with a cloud architecture usually involves an integration of S3 and Lambda function to our transformation layer, this of course in an AWS environment, so we can emulate this architecture that will be replicable across many ETLs. To accomplish this we must leverage on Airflow as our data orchestrator (at least for our ingestion layer) S3+Lambda that will work to as our transformation trigger, which will be a docker container/s that will handle our transformation. So we could build a replicable architecture like the following, and totally decoupled:

Ingestion → Airflow: every day/minute/etc we will can a third-party provider (API) and get some data, after this we will load it into a S3 bucket (are we going to ingest per call, bulk, etc?? this may depend, but in essence is the same approach)

Transformation → Docker: we will build a Transformation app (containerized) that will receive our API call as input, do some transformation (data validation, numeric enrichment, etc. Basically whatever we want).

Load → We are working in S3, so we can store our processed data in a dedicated bucket, and later launch a new lambda function that will load our data in a final DB for example (we will cover this later using a local db)
