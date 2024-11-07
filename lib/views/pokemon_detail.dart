import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/models/pokemon_model.dart';

class PokemonDetailScreen extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonDetailScreen({
    Key? key,
    required this.pokemon,
  }) : super(key: key);

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.yellow;
      case 'psychic':
        return Colors.purple;
      case 'normal':
        return Colors.grey;
      case 'fighting':
        return Colors.brown;
      case 'flying':
        return Colors.lightBlue;
      case 'poison':
        return Colors.deepPurple;
      case 'ground':
        return Colors.brown[300]!;
      case 'rock':
        return Colors.grey[700]!;
      case 'bug':
        return Colors.lightGreen;
      case 'ghost':
        return Colors.indigo;
      case 'steel':
        return Colors.blueGrey;
      case 'dragon':
        return Colors.indigo[700]!;
      case 'dark':
        return Colors.grey[900]!;
      case 'fairy':
        return Colors.pink;
      case 'ice':
        return Colors.lightBlue[100]!;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pokemon.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagem em alta resolução
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              child: Hero(
                tag: 'pokemon-${pokemon.id}',
                child: CachedNetworkImage(
                  imageUrl: 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${pokemon.id.toString().padLeft(3, '0')}.png',
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Informações básicas
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID e Nome
                  Text(
                    '#${pokemon.id.toString().padLeft(3, '0')} - ${pokemon.name}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  // Tipos
                  const Text(
                    'Types:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8,
                    children: pokemon.type.map((type) {
                      return Chip(
                        backgroundColor: _getTypeColor(type),
                        label: Text(
                          type,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Stats
                  const Text(
                    'Base Stats:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...pokemon.base.entries.map((stat) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(
                                  stat.key,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: stat.value / 200, // Normalizado para max 200
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    stat.value > 100 ? Colors.green : Colors.blue,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 40,
                                child: Text(
                                  stat.value.toString(),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}