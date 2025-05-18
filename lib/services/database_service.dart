import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<void> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'history.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE history(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          calculation TEXT,
          timestamp TEXT
        )
      ''');
    });
  }

  Future<void> insertHistory(String calculation, String timestamp) async {
    await _db?.insert('history', {'calculation': calculation, 'timestamp': timestamp});
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    return await _db?.query('history', orderBy: 'id DESC') ?? [];
  }
}