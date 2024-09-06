import 'package:flutter/material.dart';
import '/repositories/funcionario_reposity.dart';
import '/models/funcionario.dart';
import 'add_edit_funcionario_screen.dart';
import 'funcionario_list_item.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FuncionarioRepository _repository = FuncionarioRepository();
  List<Funcionario> _funcionarios = [];
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFuncionarios();
  }

  Future<void> _loadFuncionarios() async {
    final funcionarios = await _repository.getAllFuncionarios();
    setState(() {
      _funcionarios = funcionarios;
    });
  }

  void _filterFuncionarios(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _navigateToAddEditScreen({Funcionario? funcionario}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddEditFuncionarioScreen(funcionario: funcionario),
      ),
    );

    if (result == true) {
      _loadFuncionarios();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredFuncionarios = _funcionarios
        .where((f) => f.nome.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                decoration: const InputDecoration(
                  hintText: 'Pesquisar funcionário...',
                  border: InputBorder.none,
                ),
                onChanged: _filterFuncionarios,
              )
            : Text('Cadastro de Funcionários'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: filteredFuncionarios.isEmpty
          ? const Center(child: Text('Nenhum funcionário encontrado.'))
          : ListView.builder(
              itemCount: filteredFuncionarios.length,
              itemBuilder: (context, index) {
                return FuncionarioListItem(
                  funcionario: filteredFuncionarios[index],
                  onDelete: () async {
                    await _repository
                        .deleteFuncionario(filteredFuncionarios[index].id!);
                    _loadFuncionarios();
                  },
                  onEdit: () => _navigateToAddEditScreen(
                      funcionario: filteredFuncionarios[index]),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(),
        child: Icon(Icons.add),
      ),
    );
  }
}
