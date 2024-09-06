import '/models/funcionario.dart';
import 'db_helper.dart';

class FuncionarioRepository {
  final DBHelper dbHelper = DBHelper();

  Future<void> insertFuncionario(Funcionario funcionario) async {
    await dbHelper.insertFuncionario(funcionario.toMap());
  }

  Future<void> updateFuncionario(Funcionario funcionario) async {
    await dbHelper.updateFuncionario(funcionario.toMap());
  }

  Future<void> deleteFuncionario(int id) async {
    await dbHelper.deleteFuncionario(id);
  }

  Future<List<Funcionario>> getAllFuncionarios() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('funcionario');

    return List.generate(maps.length, (i) {
      return Funcionario.fromMap(maps[i]);
    });
  }

  Future<List<Funcionario>> searchFuncionarioByName(String name) async {
    final List<Map<String, dynamic>> maps =
        await dbHelper.searchFuncionarioByName(name);
    return List.generate(maps.length, (i) {
      return Funcionario.fromMap(maps[i]);
    });
  }
}
