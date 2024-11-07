import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon_model.dart';
import '../database/captured_pokemon_database.dart';
import 'pokemon_details_screen.dart';

class MyPokemonScreen extends StatefulWidget {
  const MyPokemonScreen({Key? key}) : super(key: key);

  @override
  _MyPokemonScreenState createState() => _MyPokemonScreenState();
}

class _MyPokemonScreenState extends State<MyPokemonScreen> {
  final CapturedPokemonDatabase _capturedDb = CapturedPokemonDatabase.instance;
  List<Pokemon> _capturedPokemon = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCapturedPokemon();
  }

  Future<void> _loadCapturedPokemon() async {
    setState(() => _isLoading = true);
    try {
      final pokemonList = await _capturedDb.getCapturedPokemon();
      setState(() => _capturedPokemon = pokemonList);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading captured Pokémon: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getPokemonImageUrl(Pokemon pokemon) {
    String formattedId = pokemon.id.toString().padLeft(3, '0');
    return 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/$formattedId.png';
  }

  void _navigateToPokemonDetails(Pokemon pokemon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyPokemonDetailsScreen(pokemon: pokemon),
      ),
    ).then((_) => _loadCapturedPokemon());  // Recarrega a lista após retornar da tela de detalhes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pokémon'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _capturedPokemon.isEmpty
              ? const Center(child: Text('Você ainda não capturou nenhum Pokémon.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _capturedPokemon.length,
                  itemBuilder: (context, index) {
                    final pokemon = _capturedPokemon[index];
                    return GestureDetector(
                      onTap: () => _navigateToPokemonDetails(pokemon),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: CachedNetworkImage(
                                imageUrl: _getPokemonImageUrl(pokemon),
                                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                                fit: BoxFit.contain,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                pokemon.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                pokemon.type.join(', '),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}