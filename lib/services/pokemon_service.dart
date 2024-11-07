import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_model.dart';
import '../database/pokemon_database.dart';

class PokemonService {
  static const String baseUrl = 'http://10.0.2.2:3000/Pokemons'; // Ajuste a URL conforme seu servidor local
  final PokemonDatabase _database = PokemonDatabase.instance;

  Future<List<Pokemon>> getPokemonList(int offset, int limit) async {
    try {
      // Primeiro, tenta buscar do cache local
      final cachedPokemon = await _database.getAllPokemon(
        offset: offset,
        limit: limit,
      );

      // Se há dados no cache e não é a primeira página, retorna do cache
      if (cachedPokemon.isNotEmpty && offset > 0) {
        return cachedPokemon;
      }

      // Se não há dados no cache ou é a primeira página, busca da API
      final response = await http.get(
        Uri.parse('$baseUrl?_start=$offset&_limit=$limit'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        final pokemons = data.map((json) => Pokemon.fromJson(json)).toList();
        
        // Salva os novos dados no cache
        await _database.insertMultiplePokemon(pokemons);
        
        return pokemons;
      } else {
        // Se falhar a API, tenta retornar do cache
        if (cachedPokemon.isNotEmpty) {
          return cachedPokemon;
        }
        throw Exception('Failed to load pokemon');
      }
    } catch (e) {
      // Em caso de erro, tenta retornar do cache
      final cachedPokemon = await _database.getAllPokemon(
        offset: offset,
        limit: limit,
      );
      if (cachedPokemon.isNotEmpty) {
        return cachedPokemon;
      }
      throw Exception('Failed to load pokemon: $e');
    }
  }

  Future<Pokemon?> getPokemonDetails(int id) async {
    try {
      // Primeiro, tenta buscar do cache
      final cachedPokemon = await _database.getPokemon(id);
      if (cachedPokemon != null) {
        return cachedPokemon;
      }

      // Se não encontrou no cache, busca da API
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        final pokemon = Pokemon.fromJson(json.decode(response.body));
        // Salva no cache
        await _database.insertPokemon(pokemon);
        return pokemon;
      } else {
        throw Exception('Failed to load pokemon details');
      }
    } catch (e) {
      // Em caso de erro, tenta retornar do cache novamente
      return await _database.getPokemon(id);
    }
  }
}