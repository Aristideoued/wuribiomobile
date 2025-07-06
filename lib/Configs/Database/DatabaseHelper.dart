import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wuriproject/Models/User.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _db;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'users.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT,
        lastName TEXT,
        photoPath TEXT,
        fingerprintData TEXT,
        createdAt TEXT,
        lastLogin TEXT
      )
    ''');
  }

  // CRUD methods

  Future<int> insertUser(User user) async {
    final dbClient = await db;
    return await dbClient.insert('users', user.toMap());
  }

  Future<List<User>> getAllUsers() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('users');
    return maps.map((map) => User.fromMap(map)).toList();
  }

  Future<int> updateUser(User user) async {
    final dbClient = await db;
    return await dbClient.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<User?> getUserById(int id) async {
  final dbClient = await db;
  final List<Map<String, dynamic>> maps = await dbClient.query(
    'users',
    where: 'id = ?',
    whereArgs: [id],
  );

  if (maps.isNotEmpty) {
    return User.fromMap(maps.first);
  } else {
    return null; // Aucun utilisateur trouvé
  }
}


  Future<int> deleteUser(int id) async {
    final dbClient = await db;
    return await dbClient.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
