import 'package:flutter/material.dart';
import '/models/funcionario.dart';

class FuncionarioListItem extends StatelessWidget {
  final Funcionario funcionario;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const FuncionarioListItem({
    Key? key,
    required this.funcionario,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(funcionario.nome),
        subtitle: Text('Telefone: ${funcionario.telefone}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Confirmar exclusão'),
                    content: Text('Deseja realmente excluir este funcionário?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          onDelete();
                          Navigator.pop(context);
                        },
                        child: Text('Excluir'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
