from pokeapi import PokeAPI, PokemonDetails
import datetime
from .utils.file_manager import FileManager

def save_response_as_json(
        file_name: str,
        data: PokemonDetails) -> None:

    data_json = data.model_dump()
    file_manager = FileManager()

    file_manager.save_json(path=file_name, data=data_json)


def get_pokemon_details(pokemon_name: str) -> PokemonDetails:
    api = PokeAPI()
    response = api.pokemon.get_details(
        pokemon_id=pokemon_name
    )
    return response

def main():
    pokemon_name = "pikachu"
    pokemon_data = get_pokemon_details(pokemon_name=pokemon_name)

    now_str = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    file_name = f"example_response/{pokemon_name}_{now_str}.json"
    save_response_as_json(file_name=file_name, data=pokemon_data)


if __name__ == "__main__":
    main()
