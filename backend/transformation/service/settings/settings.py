from dataclasses import dataclass


@dataclass
class ScoreWeights:
    base_experience: float = 0.40
    height: float = 0.05
    order: float =  0.20
    weight: float =  0.10
    number_of_abilities: float =  0.25

@dataclass
class Inputs:
    id_: str = "id"
    name: str = "name"
    base_experience: str = "base_experience"
    height: str = "height"
    order: str = "order"
    weight: str = "weight"
    abilities: str = "abilities"

@dataclass
class TransformSettings:
    inputs: Inputs = Inputs()
    score_weights: ScoreWeights = ScoreWeights()