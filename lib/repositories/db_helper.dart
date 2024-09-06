import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();

  factory DBHelper() => _instance;

  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'funcionarios.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createLogTableAndTriggers(db);
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE funcionario(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        telefone INTEGER NOT NULL UNIQUE CHECK (telefone > 0)
      )
    ''');

    await _createLogTableAndTriggers(db);
  }

  Future<void> insertFuncionario(Map<String, dynamic> funcionario) async {
    final db = await database;
    try {
      await db.insert('funcionario', funcionario);
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('UNIQUE constraint failed')) {
        errorMessage = 'Telefone já está em uso.';
      } else if (e.toString().contains('CHECK constraint failed')) {
        errorMessage = 'O telefone deve ser um número maior que zero.';
      } else {
        errorMessage = 'Erro inesperado ao inserir o funcionário.';
      }
      throw Exception(errorMessage);
    }
  }

  Future<void> updateFuncionario(Map<String, dynamic> funcionario) async {
    final db = await database;
    try {
      await db.update(
        'funcionario',
        funcionario,
        where: 'id = ?',
        whereArgs: [funcionario['id']],
      );
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('UNIQUE constraint failed')) {
        errorMessage = 'Telefone já está em uso.';
      } else if (e.toString().contains('CHECK constraint failed')) {
        errorMessage = 'O telefone deve ser um número maior que zero.';
      } else {
        errorMessage = 'Erro inesperado ao atualizar o funcionário.';
      }
      throw Exception(errorMessage);
    }
  }

  Future<void> deleteFuncionario(int id) async {
    final db = await database;
    await db.delete(
      'funcionario',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> searchFuncionarioByName(
      String name) async {
    final db = await database;
    return await db.query(
      'funcionario',
      where: 'nome LIKE ?',
      whereArgs: ['%$name%'],
    );
  }

  Future _createLogTableAndTriggers(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS operacao_log(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT NOT NULL,
        data TEXT DEFAULT (DATETIME('now', 'localtime'))
      )
    ''');

    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS after_funcionario_insert
      AFTER INSERT ON funcionario
      BEGIN
        INSERT INTO operacao_log(tipo, data)
        VALUES ('Insert', DATETIME('now', 'localtime'));
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS after_funcionario_update
      AFTER UPDATE ON funcionario
      BEGIN
        INSERT INTO operacao_log(tipo, data)
        VALUES ('Update', DATETIME('now', 'localtime'));
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS after_funcionario_delete
      AFTER DELETE ON funcionario
      BEGIN
        INSERT INTO operacao_log(tipo, data)
        VALUES ('Delete', DATETIME('now', 'localtime'));
      END;
    ''');
  }
}
