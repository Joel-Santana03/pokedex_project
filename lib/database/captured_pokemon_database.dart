import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pokemon_model.dart';
import 'dart:convert';

class CapturedPokemonDatabase {
  static final CapturedPokemonDatabase instance = CapturedPokemonDatabase._init();
  static Database? _database;

  CapturedPokemonDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('captured_pokemon.db');
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
      CREATE TABLE captured_pokemon(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        types TEXT NOT NULL,
        base TEXT NOT NULL,
        capture_date INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_encounter(
        id INTEGER PRIMARY KEY,
        pokemon_id INTEGER NOT NULL,
        encounter_date INTEGER NOT NULL
      )
    ''');
  }

  Future<bool> canCapturePokemon() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM captured_pokemon')
    );
    return (count ?? 0) < 6;
  }

  Future<void> capturePokemon(Pokemon pokemon) async {
    final db = await database;
    await db.insert(
      'captured_pokemon',
      {
        'id': pokemon.id,
        'name': pokemon.name,
        'types': jsonEncode(pokemon.type),
        'base': jsonEncode(pokemon.base),
        'capture_date': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveDailyEncounter(int pokemonId) async {
    final db = await database;
    await db.insert(
      'daily_encounter',
      {
        'pokemon_id': pokemonId,
        'encounter_date': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int?> getLastEncounteredPokemonId() async {
    final db = await database;
    final result = await db.query(
      'daily_encounter',
      orderBy: 'encounter_date DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['pokemon_id'] as int;
    }
    return null;
  }

  Future<bool> isNewDayForEncounter() async {
    final db = await database;
    final result = await db.query(
      'daily_encounter',
      orderBy: 'encounter_date DESC',
      limit: 1,
    );
    
    if (result.isEmpty) return true;
    
    final lastEncounterDate = DateTime.fromMillisecondsSinceEpoch(
      result.first['encounter_date'] as int
    );
    final now = DateTime.now();
    
    return !_isSameDay(lastEncounterDate, now);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

    Future<List<Pokemon>> getCapturedPokemon() async {
    final db = await database;
    final result = await db.query('captured_pokemon', orderBy: 'capture_date DESC');
    
    return result.map((map) => Pokemon(
      id: map['id'] as int,
      name: map['name'] as String,
      type: List<String>.from(jsonDecode(map['types'] as String)),
      base: Map<String, int>.from(jsonDecode(map['base'] as String)),
    )).toList();
  }

  Future<void> releasePokemon(int id) async {
    final db = await database;
    await db.delete(
      'captured_pokemon',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}

