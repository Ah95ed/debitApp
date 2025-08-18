import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/debt_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    // from windows
    //  sqfliteFfiInit();
    if (Platform.isWindows) {
      databaseFactory = databaseFactoryFfi;
    }

    if (_database != null) return _database!;
    _database = await _initDB('debts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE debts (
  id $idType,
  phoneNumber $textType UNIQUE,
  name $textType,
  amount $doubleType,
  date $textType,
  note $textType,
  status $textType,
  lastUpdated $intType
)''');
  }

  Future<void> addOrUpdateDebt(Debt debt) async {
    final db = await instance.database;
    await db.insert(
      'debts',
      debt.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Debt?> getDebtByPhoneNumber(String phoneNumber) async {
    final db = await instance.database;
    final maps = await db.query(
      'debts',
      columns: [
        'id',
        'phoneNumber',
        'name',
        'amount',
        'date',
        'note',
        'status',
        'lastUpdated',
      ],
      where: 'phoneNumber = ?',
      whereArgs: [phoneNumber],
    );

    if (maps.isNotEmpty) {
      return Debt.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Debt>> getAllDebts() async {
    final db = await instance.database;
    final result = await db.query('debts', orderBy: 'date DESC');
    return result.map((json) => Debt.fromMap(json)).toList();
  }

  Future<int> deleteDebt(String phoneNumber) async {
    final db = await instance.database;
    return await db.delete(
      'debts',
      where: 'phoneNumber = ?',
      whereArgs: [phoneNumber],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
