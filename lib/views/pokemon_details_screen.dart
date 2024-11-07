import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../models/pokemon_model.dart';
import '../database/captured_pokemon_database.dart';
import '../services/pokemon_service.dart';

class MyPokemonDetailsScreen extends StatefulWidget {
  final Pokemon pokemon;

  const MyPokemonDetailsScreen({Key? key, required this.pokemon}) : super(key: key);

  @override
  _MyPokemonDetailsScreenState createState() => _MyPokemonDetailsScreenState();
}

class _MyPokemonDetailsScreenState extends State<MyPokemonDetailsScreen> {
  final CapturedPokemonDatabase _capturedDb = CapturedPokemonDatabase.instance;
  final PokemonService _pokemonService = PokemonService();
  late Future<Pokemon> _pokemonDetails;

  @override
  void initState() {
    super.initState();
    _pokemonDetails = _loadPokemonDetails();
  }

  Future<Pokemon> _loadPokemonDetails() async {
    try {
      // Tenta buscar dados atualizados da API
      final updatedPokemon = await _pokemonService.getPokemonDetails(widget.pokemon.id);
      return updatedPokemon ?? widget.pokemon;
    } catch (e) {
      // Em caso de erro, usa os dados do cache
      print('Error loading pokemon details: $e');
      return widget.pokemon;
    }
  }

  String _getHighResImageUrl(Pokemon pokemon) {
    String formattedId = pokemon.id.toString().padLeft(3, '0');
    return 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/$formattedId.png';
  }

  void _showReleaseDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Soltar Pokémon',
      desc: 'Tem certeza que deseja soltar ${widget.pokemon.name}?',
      btnCancelText: 'Cancelar',
      btnOkText: 'Soltar',
      btnCancelOnPress: () {},
      btnOkOnPress: () => _releasePokemon(),
    )..show();
  }

  Future<void> _releasePokemon() async {
    try {
      await _capturedDb.releasePokemon(widget.pokemon.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.pokemon.name} foi solto com sucesso!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao soltar Pokémon: $e')),
        );
      }
    }
  }

  Widget _buildStatBar(String label, int value, {Color color = Colors.blue}) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: LinearProgressIndicator(
                value: value / 200, // Normaliza o valor para uma escala de 0 a 1
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(
                value.toString(),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pokemon.name),
      ),
      body: FutureBuilder<Pokemon>(
        future: _pokemonDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final pokemon = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Hero(
                            tag: 'pokemon-${pokemon.id}',
                            child: CachedNetworkImage(
                              imageUrl: _getHighResImageUrl(pokemon),
                              height: 200,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.error,
                                size: 60,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            pokemon.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: pokemon.type.map((type) => Chip(
                              label: Text(type),
                              backgroundColor: Colors.blue.withOpacity(0.2),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estatísticas Base',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStatBar('HP', pokemon.base['HP'] ?? 0, color: Colors.green),
                          _buildStatBar('Ataque', pokemon.base['Attack'] ?? 0, color: Colors.red),
                          _buildStatBar('Defesa', pokemon.base['Defense'] ?? 0, color: Colors.blue),
                          _buildStatBar('Sp. Atk', pokemon.base['Sp. Attack'] ?? 0, color: Colors.purple),
                          _buildStatBar('Sp. Def', pokemon.base['Sp. Defense'] ?? 0, color: Colors.teal),
                          _buildStatBar('Velocidade', pokemon.base['Speed'] ?? 0, color: Colors.orange),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
ElevatedButton.icon(
  onPressed: _showReleaseDialog,
  icon: const Icon(Icons.logout),
  label: const Text('Soltar Pokémon'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
    padding: const EdgeInsets.symmetric(vertical: 12),
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