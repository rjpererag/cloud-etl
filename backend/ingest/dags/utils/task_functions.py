from pokeapi import PokeAPI, PokemonDetails

def get_pokemon_details(pokemon_name: str) -> str | None:
    api = PokeAPI()
    response = api.pokemon.get_details(
        pokemon_id=pokemon_name
    )

    if isinstance(response, PokemonDetails):
        return response.model_dump_json(indent=2)
    return None