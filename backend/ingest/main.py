from dags.utils.task_functions import get_pokemon_details, build_object_to_load

def main():
    pokemon_name = "pikachu"
    pokemon_data = get_pokemon_details(pokemon_name=pokemon_name)
    object_to_save = build_object_to_load(name=pokemon_name, details=pokemon_data)
    print(object_to_save)


if __name__ == "__main__":
    main()
