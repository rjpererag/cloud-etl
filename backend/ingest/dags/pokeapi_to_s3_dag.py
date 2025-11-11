from __future__ import annotations
import pendulum
import logging
import os

from airflow.sdk import dag, task
from utils.task_functions import get_pokemon_details
from airflow.providers.amazon.aws.hooks.s3 import S3Hook

log = logging.getLogger(__name__)

S3_CONN_ID = os.getenv("AWS_CONNECTION_ID", "aws_connection")
S3_BUCKET = os.getenv("S3_RAW_BUCKET", "s3_raw_bucket")

@task.bash
def print_pokemon_name(name: str):
    return f'''
    echo "CONNECTION: {S3_CONN_ID}"
    echo "GETTING POKEMON: {name.upper()} DATA"
'''

@task
def get_pokemon_data(pokemon_name: str) -> str | None:
    pokemon_details = get_pokemon_details(pokemon_name=pokemon_name)
    return pokemon_details


@task.bash
def print_pokemon_details(
        pokemon_name: str, details: dict | None):
    if details is None:
        return f'echo "Pokemon {pokemon_name} details not found"'
    return f'''
    echo "Pokemon {pokemon_name}: {details}"
    echo "data type {type(details)}"
'''


@task
def load_to_s3(name: str, details: str | None) -> None:
    hook = S3Hook(aws_conn_id=S3_CONN_ID)

    now_str = pendulum.now("UTC").strftime("%Y%m%d%H%M%S")
    s3_key = f"{name}_{now_str}.json"

    if not details:
        file_content = '{"status": "failed", ,"timestamp": "2025-10-13-10:03"}'
    else:
        file_content = '{"status": "ready", "data:"' + details + '"timestamp": "2025-10-13-10:03"}'


    log.info(f"Writing file {s3_key} to S3 bucket {S3_BUCKET}")
    hook.load_string(
        string_data=file_content,
        key=s3_key,
        bucket_name=S3_BUCKET,
        replace=True,
    )

    log.info(f"File creation simulated and complete {file_content}")


@dag(
    dag_id="pokeapi_to_s3",
    default_args={"owner": "senior_data_engineer",
                  "retries": 1,
                  "poke_interval": 30},
    start_date=pendulum.datetime(2025, 10, 8, tz="UTC"),
    schedule=None,
    catchup=False,
    tags=["s3"],
)
def pokeapi_to_s3_dag():
    pokemon_name = "pikachu"
    print_name_task = print_pokemon_name(pokemon_name)
    get_details_task = get_pokemon_data(pokemon_name)
    print_details_task = print_pokemon_details(pokemon_name, get_details_task)
    load_task = load_to_s3(pokemon_name, get_details_task)

    print_name_task >> get_details_task >> print_details_task >> load_task

pokeapi_to_s3_dag()
