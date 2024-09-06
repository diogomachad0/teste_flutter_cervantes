class Funcionario {
  final int? id;
  final String nome;
  final int telefone;

  Funcionario({this.id, required this.nome, required this.telefone});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'telefone': telefone,
    };
  }

  factory Funcionario.fromMap(Map<String, dynamic> map) {
    return Funcionario(
      id: map['id'],
      nome: map['nome'],
      telefone: map['telefone'],
    );
  }
}
