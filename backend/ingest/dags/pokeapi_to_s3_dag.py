import pendulum
from airflow.sdk import dag, task
from pokeapi import Poke


@task.bash
def print_pokemon_name(name: str):
    return f'echo "GETTING POKEMON: {name.upper()} DATA"'

@task
def get_pokemon_data(pokemon_name: str):
    pass

@task.bash
def load_to_s3():
    return 'echo "LOADING TO S3"'


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
    print_task = print_pokemon_name(pokemon_name)
    get_task = get_pokemon_data(pokemon_name)
    load_task = load_to_s3()

    print_task >> get_task >> load_task

pokeapi_to_s3_dag()
