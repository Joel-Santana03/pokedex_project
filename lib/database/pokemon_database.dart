import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pokemon_model.dart';

class PokemonDatabase {
  static final PokemonDatabase instance = PokemonDatabase._init();
  static Database? _database;

  PokemonDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pokemon.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pokemon(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        types TEXT NOT NULL,
        base TEXT NOT NULL,
        last_updated INTEGER NOT NULL
      )
    ''');
  }

  Future<void> insertPokemon(Pokemon pokemon) async {
    final db = await database;
    await db.insert(
      'pokemon',
      {
        'id': pokemon.id,
        'name': pokemon.name,
        'types': jsonEncode(pokemon.type),
        'base': jsonEncode(pokemon.base),
        'last_updated': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertMultiplePokemon(List<Pokemon> pokemons) async {
    final db = await database;
    final batch = db.batch();
    
    for (var pokemon in pokemons) {
      batch.insert(
        'pokemon',
        {
          'id': pokemon.id,
          'name': pokemon.name,
          'types': jsonEncode(pokemon.type),
          'base': jsonEncode(pokemon.base),
          'last_updated': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  Future<Pokemon?> getPokemon(int id) async {
    final db = await database;
    final maps = await db.query(
      'pokemon',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Pokemon(
        id: maps[0]['id'] as int,
        name: maps[0]['name'] as String,
        type: List<String>.from(jsonDecode(maps[0]['types'] as String)),
        base: Map<String, int>.from(jsonDecode(maps[0]['base'] as String)),
      );
    }
    return null;
  }

  Future<List<Pokemon>> getAllPokemon({int? limit, int? offset}) async {
    final db = await database;
    final maps = await db.query(
      'pokemon',
      orderBy: 'id ASC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => Pokemon(
      id: map['id'] as int,
      name: map['name'] as String,
      type: List<String>.from(jsonDecode(map['types'] as String)),
      base: Map<String, int>.from(jsonDecode(map['base'] as String)),
    )).toList();
  }

  Future<bool> isDatabaseEmpty() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM pokemon')
    );
    return count == 0;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}