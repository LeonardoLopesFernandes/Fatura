class Comprador {
  final String id;
  final String nome;

  Comprador({required this.id, required this.nome});

  Map<String, dynamic> toJson() => {'id': id, 'nome': nome};

  factory Comprador.fromJson(Map<String, dynamic> json) =>
      Comprador(id: json['id'], nome: json['nome']);
}
