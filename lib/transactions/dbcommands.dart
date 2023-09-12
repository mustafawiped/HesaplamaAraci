import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class DBCommands {
  Database? _database;

  Future<void> initializeDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'database.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE veriler (id INTEGER PRIMARY KEY, islem TEXT, sonuc TEXT)',
        );
      },
    );
  }

  Future<void> insertData(String transaction, String result) async {
    await _database!.insert(
      'veriler',
      {'islem': transaction, 'sonuc': result},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateData(int id, String transaction, String result) async {
    await _database!.update(
      'veriler',
      {'islem': transaction, 'sonuc': result},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteData(int id) async {
    await _database!.delete(
      'veriler',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllData() async {
    await _database!.delete('veriler');
  }

  Future<List<Map<String, dynamic>>> getAllData() async {
    if (_database != null) {
      return await _database!.query('veriler', orderBy: 'id DESC');
    } else {
      return [];
    }
  }

  Future<void> closeDatabase() async {
    await _database!.close();
  }
}