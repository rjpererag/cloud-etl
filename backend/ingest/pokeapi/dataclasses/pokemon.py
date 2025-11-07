from pydantic import BaseModel


class Ability(BaseModel):
    name: str
    url: str

class PokemonAbility(BaseModel):
    is_hidden: bool
    slot: int
    ability: Ability

class PokemonDetails(BaseModel):
    id: int
    name: str
    base_experience: int
    height: int
    order: int
    weight: int
    abilities: list[PokemonAbility]
