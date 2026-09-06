class Banco {
  final String id;
  final String nome;
  final int cor; // ARGB como int (ex: 0xFF8A05BE)
  final String? iconeChave;
  final String? iconeRes;
  final String? iconeArquivo;
  final int? corDoIcone;
  final String? chavePix;
  final int? diaVencimento;

  Banco({
    required this.id,
    required this.nome,
    required this.cor,
    this.iconeChave,
    this.iconeRes,
    this.iconeArquivo,
    this.corDoIcone,
    this.chavePix,
    this.diaVencimento,
  });

  bool temLogo() => iconeRes != null || iconeArquivo != null;

  Banco copyWith({
    String? id,
    String? nome,
    int? cor,
    String? iconeChave,
    String? iconeRes,
    String? iconeArquivo,
    int? corDoIcone,
    String? chavePix,
    int? diaVencimento,
  }) {
    return Banco(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cor: cor ?? this.cor,
      iconeChave: iconeChave ?? this.iconeChave,
      iconeRes: iconeRes ?? this.iconeRes,
      iconeArquivo: iconeArquivo ?? this.iconeArquivo,
      corDoIcone: corDoIcone ?? this.corDoIcone,
      chavePix: chavePix ?? this.chavePix,
      diaVencimento: diaVencimento ?? this.diaVencimento,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'cor': cor,
        if (iconeChave != null) 'iconeChave': iconeChave,
        if (iconeRes != null) 'iconeRes': iconeRes,
        if (iconeArquivo != null) 'iconeArquivo': iconeArquivo,
        if (corDoIcone != null) 'corDoIcone': corDoIcone,
        if (chavePix != null) 'chavePix': chavePix,
        if (diaVencimento != null) 'diaVencimento': diaVencimento,
      };

  factory Banco.fromJson(Map<String, dynamic> json) => Banco(
        id: json['id'],
        nome: json['nome'],
        cor: json['cor'],
        iconeChave: json['iconeChave'],
        iconeRes: json['iconeRes'],
        iconeArquivo: json['iconeArquivo'],
        corDoIcone: json['corDoIcone'],
        chavePix: json['chavePix'],
        diaVencimento: json['diaVencimento'],
      );
}
