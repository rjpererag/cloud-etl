from .endpoint import Endpoint
from ..dataclasses import PokemonDetails


class Pokemon(Endpoint):

    def __init__(self, host: str, headers: dict = None):
        super().__init__(host=host, headers=headers)

    def get_details(self, pokemon_id: str) -> PokemonDetails:
        """https://pokeapi.co/api/v2/pokemon/{id or name}/"""
        endpoint = f"api/v2/pokemon/{pokemon_id}"
        response = self.get(
            endpoint=endpoint,
        )
        return PokemonDetails(**response)

