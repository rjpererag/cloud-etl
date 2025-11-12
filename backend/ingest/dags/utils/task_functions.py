import json
import pendulum

from pokeapi import PokeAPI, PokemonDetails

def get_pokemon_details(pokemon_name: str) -> str | None:
    api = PokeAPI()
    response = api.pokemon.get_details(
        pokemon_id=pokemon_name
    )

    if isinstance(response, PokemonDetails):
        return response.model_dump_json(indent=2)
    return None


def build_object_to_load(name: str, details: str | None) -> dict:
    now_str = pendulum.now("UTC").strftime("%Y%m%d%H%M%S")
    s3_key = f"{name}_{now_str}.json"

    if not details:
        file_content = {"status": "failed","timestamp": now_str}
    else:
        file_content = {"status": "ready", "data": details, "timestamp": now_str}

    return {
        "s3_key": s3_key,
        "file_content": json.dumps(file_content)
    }
