import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pokedex_app/views/pokemon_detail.dart';
import '/models/pokemon_model.dart';
import '/services/pokemon_service.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({Key? key}) : super(key: key);

  @override
  _PokedexScreenState createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  static const _pageSize = 20;
  final PagingController<int, Pokemon> _pagingController =
      PagingController(firstPageKey: 0);
  final PokemonService _pokemonService = PokemonService();

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

Future<void> _fetchPage(int pageKey) async {
  try {
    final newItems = await _pokemonService.getPokemonList(pageKey, _pageSize);
    final isLastPage = newItems.length < _pageSize;
    if (isLastPage) {
      _pagingController.appendLastPage(newItems);
    } else {
      final nextPageKey = pageKey + newItems.length;
      _pagingController.appendPage(newItems, nextPageKey);
    }
  } catch (error) {
    _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
      ),
      body: PagedListView<int, Pokemon>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Pokemon>(
          itemBuilder: (context, pokemon, index) => PokemonCard(pokemon: pokemon),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonCard({Key? key, required this.pokemon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: CachedNetworkImage(
          imageUrl: 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${pokemon.id.toString().padLeft(3, '0')}.png',
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
        title: Text(pokemon.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Types: ${pokemon.type.join(", ")}'),
            Text('HP: ${pokemon.base['HP']} | Attack: ${pokemon.base['Attack']}'),
          ],
        ),
// No PokemonCard, atualize o onTap:
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PokemonDetailScreen(pokemon: pokemon),
    ),
  );
},
      ),
    );
  }
}