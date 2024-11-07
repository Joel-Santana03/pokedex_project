import 'package:pokedex_app/database/database_helper.dart';

class PokemonRepository {
// Inserir um Pokémon
Future<void> addPokemon() async {
  await DatabaseHelper.instance.insertPokemon({
    'name': 'Pikachu',
    'type': 'Electric'
  });
}

// Obter todos os Pokémons
Future<void> getAllPokemons() async {
  List<Map<String, dynamic>> pokemons = await DatabaseHelper.instance.queryAllPokemons();
  for (var pokemon in pokemons) {
    print(pokemon);
  }
}

// Atualizar um Pokémon
Future<void> updatePokemon() async {
  await DatabaseHelper.instance.updatePokemon({
    'id': 1,
    'name': 'Raichu',
    'type': 'Electric'
  });
}

// Deletar um Pokémon
Future<void> deletePokemon() async {
  await DatabaseHelper.instance.deletePokemon(1);
}
}