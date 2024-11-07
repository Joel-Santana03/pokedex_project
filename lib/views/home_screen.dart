import 'package:flutter/material.dart';
import 'package:pokedex_app/views/daily_encounter_screen.dart';
import 'package:pokedex_app/views/my_pokemon_screen.dart';
import 'package:pokedex_app/views/pokedex_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
// No botão Pokédex
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PokedexScreen()),
    );
  },
  child: const Text('Pokédex'),
),
            const SizedBox(height: 20),
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DailyEncounterScreen()),
    );
  },
              child: const Text('Encontro Diário'),
            ),
            const SizedBox(height: 20),
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyPokemonScreen()),
    );
  },
              child: const Text('Meus Pokémons'),
            ),
          ],
        ),
      ),
    );
  }
}