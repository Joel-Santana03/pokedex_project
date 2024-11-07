import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pokemons.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE pokemons (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      type TEXT NOT NULL
    )
    ''');
  }

  Future<int> insertPokemon(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('pokemons', row);
  }

  Future<List<Map<String, dynamic>>> queryAllPokemons() async {
    final db = await instance.database;
    return await db.query('pokemons');
  }

  Future<int> updatePokemon(Map<String, dynamic> row) async {
    final db = await instance.database;
    int id = row['id'];
    return await db.update('pokemons', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePokemon(int id) async {
    final db = await instance.database;
    return await db.delete('pokemons', where: 'id = ?', whereArgs: [id]);
  }
}