import 'package:flutter/material.dart';
import '/repositories/funcionario_reposity.dart';
import '/models/funcionario.dart';

class AddEditFuncionarioScreen extends StatefulWidget {
  final Funcionario? funcionario;

  AddEditFuncionarioScreen({this.funcionario});

  @override
  _AddEditFuncionarioScreenState createState() =>
      _AddEditFuncionarioScreenState();
}

class _AddEditFuncionarioScreenState extends State<AddEditFuncionarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final FuncionarioRepository _repository = FuncionarioRepository();

  @override
  void initState() {
    super.initState();
    if (widget.funcionario != null) {
      _nomeController.text = widget.funcionario!.nome;
      _telefoneController.text = widget.funcionario!.telefone.toString();
    }
  }

  Future<void> _saveFuncionario() async {
    if (_formKey.currentState!.validate()) {
      final nome = _nomeController.text;
      final telefone = int.tryParse(_telefoneController.text) ?? 0;

      try {
        if (widget.funcionario == null) {
          await _repository
              .insertFuncionario(Funcionario(nome: nome, telefone: telefone));
        } else {
          final updatedFuncionario = Funcionario(
            id: widget.funcionario!.id,
            nome: nome,
            telefone: telefone,
          );
          await _repository.updateFuncionario(updatedFuncionario);
        }
        Navigator.pop(context, true);
      } catch (e) {
        await _showErrorDialog(e.toString());
      }
    }
  }

  Future<void> _showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erro'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.funcionario == null
            ? 'Adicionar Funcionário'
            : 'Editar Funcionário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _telefoneController,
                decoration: InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o telefone';
                  } else if (int.tryParse(value) == null) {
                    return 'Por favor, insira um número válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveFuncionario,
                child:
                    Text(widget.funcionario == null ? 'Adicionar' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
