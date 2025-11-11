FROM python:3.10-slim

WORKDIR ./app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV RAW_BUCKET=cloud-etl-pokeapi-raw-data
ENV PROCESSED_BUCKET=cloud-etl-pokeapi-processed-data
ENV S3_RAW_KEY=myrawkey

CMD ["python", "entrypoint.py"]