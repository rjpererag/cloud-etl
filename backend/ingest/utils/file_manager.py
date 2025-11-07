import json

class FileManager:

    @staticmethod
    def save_json(path: str, data: list | dict) -> None:
        with open(path, 'w') as json_file:
            json.dump(data, json_file, indent=2)

    @staticmethod
    def load_json(path: str) -> list | dict:
        with open(path, 'w') as json_file:
            return json.load(json_file, indent=2)
