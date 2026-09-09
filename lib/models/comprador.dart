class Comprador {
  final String id;
  final String nome;
  final String? avatarChave;
  final String? avatarArquivo;

  Comprador({
    required this.id,
    required this.nome,
    this.avatarChave,
    this.avatarArquivo,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        if (avatarChave != null) 'avatarChave': avatarChave,
        if (avatarArquivo != null) 'avatarArquivo': avatarArquivo,
      };

  factory Comprador.fromJson(Map<String, dynamic> json) => Comprador(
        id: json['id'],
        nome: json['nome'],
        avatarChave: json['avatarChave'],
        avatarArquivo: json['avatarArquivo'],
      );

  Comprador copyWith({
    String? id,
    String? nome,
    String? avatarChave,
    String? avatarArquivo,
  }) {
    return Comprador(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      avatarChave: avatarChave ?? this.avatarChave,
      avatarArquivo: avatarArquivo ?? this.avatarArquivo,
    );
  }
}
