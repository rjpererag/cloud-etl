from .service import *


class PokeAPI:

    def __init__(self):

        self.host = "pokeapi.co"

        self.pokemon = Pokemon(
            host=self.host,
            headers=None
        )