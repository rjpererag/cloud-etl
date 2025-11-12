from .settings import TransformSettings

class TransformLayer:

    def __init__(self, settings: TransformSettings = TransformSettings()):
        self.settings = settings
        self.inputs = settings.inputs
        self.score_weights = settings.score_weights

    @staticmethod
    def _check_numeric(value) -> int | float:
        if (not value) or (not isinstance(value, int | float)):
            return 0
        return value

    @staticmethod
    def _normalize(data: dict) -> dict:
        total_sum = sum([val[0] for val in data.values()])
        normalized = {key: (value[0]/total_sum, value[1]) for key, value in data.items()}
        return normalized

    @staticmethod
    def _calculate_score(data: dict) -> dict:
        score = {f"{key}_score": round(100*value[0]*value[1], 3) for key, value in data.items()}
        final_score  = round(sum(score.values()), 3)
        return {**score, "score": final_score}

    def _build_params_mapping(self, data: dict, **kwargs) -> dict:
        params = {
            self.inputs.base_experience: (
                data.get(self.inputs.base_experience, 0), self.score_weights.base_experience
            ),
            self.inputs.height: (
                data.get(self.inputs.height, 0), self.score_weights.height
            ),
            self.inputs.order: (
                data.get(self.inputs.order, 0), self.score_weights.order
            ),
            self.inputs.weight: (
                data.get(self.inputs.weight, 0), self.score_weights.weight
            ),
            "number_of_abilities": (
                kwargs.get("number_of_abilities", 0), self.score_weights.number_of_abilities
            ),
        }
        return params

    def _create_score(self, data: dict, **kwargs) -> dict:

        params = self._build_params_mapping(
            data=data, number_of_abilities=kwargs.get("number_of_abilities")
        )

        params_reviewed = {
            key: (self._check_numeric(value=value[0]), value[1]) for key, value in params.items()
        }

        params_normalized = self._normalize(data=params_reviewed)

        score = self._calculate_score(data=params_normalized)

        return score


    def augment_data(self, data: dict) -> dict:
        """
        Add new columns (is_valid, number of abilities, create score)
        """
        number_of_abilities = len(data.get('abilities', []))
        score = self._create_score(data=data, number_of_abilities=number_of_abilities)
        return {
            "number_of_abilities": number_of_abilities,
            **score,
        }


    @staticmethod
    def _validate_id(id_) -> int | float:
        return isinstance(id_, int)

    @staticmethod
    def _validate_name(name) -> int | float:
        return (name is not None) and isinstance(name, str)


    def validate(self, data: dict) -> bool:
        """Validate data: has a valid name or id"""
        validation = [
            self._validate_id(id_=data.get(self.inputs.id_)),
            self._validate_name(name=data.get(self.inputs.name)),
        ]

        return all(validation)

    def transform(self, data: dict) -> dict:
        validation = self.validate(data=data['data'])
        data["is_valid"] = validation
        if not validation:
            return {**data, "status": "not processed"}

        data = {
            **data,
            "status": "processed",
            "is_valid": validation,
            "augmentation": self.augment_data(data=data['data'])
        }
        return data