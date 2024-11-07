import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';
import '../models/pokemon_model.dart';
import '../services/pokemon_service.dart';
import '../database/captured_pokemon_database.dart';

class DailyEncounterScreen extends StatefulWidget {
  const DailyEncounterScreen({Key? key}) : super(key: key);

  @override
  _DailyEncounterScreenState createState() => _DailyEncounterScreenState();
}

class _DailyEncounterScreenState extends State<DailyEncounterScreen> {
  final PokemonService _pokemonService = PokemonService();
  final CapturedPokemonDatabase _capturedDb = CapturedPokemonDatabase.instance;
  Pokemon? _dailyPokemon;
  bool _isLoading = true;
  bool _canCapture = false;

  @override
  void initState() {
    super.initState();
    _loadDailyPokemon();
  }

  Future<void> _loadDailyPokemon() async {
    setState(() => _isLoading = true);
    try {
      final isNewDay = await _capturedDb.isNewDayForEncounter();
      if (isNewDay) {
        // Gerar novo Pokémon aleatório
        final random = Random();
        final pokemonId = random.nextInt(151) + 1; // Assumindo 151 Pokémon
        final pokemon = await _pokemonService.getPokemonDetails(pokemonId);
        if (pokemon != null) {
          await _capturedDb.saveDailyEncounter(pokemon.id);
          setState(() => _dailyPokemon = pokemon);
        }
      } else {
        // Carregar o Pokémon do dia atual
        final lastPokemonId = await _capturedDb.getLastEncounteredPokemonId();
        if (lastPokemonId != null) {
          final pokemon = await _pokemonService.getPokemonDetails(lastPokemonId);
          setState(() => _dailyPokemon = pokemon);
        }
      }

      final canCapture = await _capturedDb.canCapturePokemon();
      setState(() => _canCapture = canCapture);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _capturePokemon() async {
    if (_dailyPokemon == null) return;

    try {
      if (!_canCapture) {
        _showMaxPokemonError();
        return;
      }

      await _capturedDb.capturePokemon(_dailyPokemon!);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_dailyPokemon!.name} was captured successfully!')),
      );

      setState(() => _canCapture = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing pokemon: $e')),
      );
    }
  }

  void _showMaxPokemonError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cannot Capture'),
        content: const Text('You already have 6 Pokémon. Release one to capture more.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encontro Diário'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dailyPokemon != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CachedNetworkImage(
                      imageUrl: _dailyPokemon!.imageUrl, 
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Pokémon do Dia: ${_dailyPokemon!.name}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _capturePokemon,
                      child: const Text('Capturar Pokémon'),
                    ),
                  ],
                )
              : const Center(child: Text('Nenhum Pokémon disponível para hoje.')),
    );
  }
}