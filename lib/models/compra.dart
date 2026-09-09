import 'mes.dart';

class Compra {
  final String id;
  final String compradorId;
  final String bancoId;
  final String descricao;
  final double valorIndividual;
  final int quantidadeParcelas;
  final Mes data;
  final Set<int> pagasPorMes;
  final String? iconeChave;
  final String? iconeArquivo;
  final String? origemFixaId;

  Compra({
    required this.id,
    required this.compradorId,
    required this.bancoId,
    required this.descricao,
    required this.valorIndividual,
    required this.quantidadeParcelas,
    required this.data,
    Set<int>? pagasPorMes,
    this.iconeChave,
    this.iconeArquivo,
    this.origemFixaId,
  }) : pagasPorMes = pagasPorMes ?? {};

  double get valorTotal => valorIndividual * quantidadeParcelas;

  Mes get dataFim => data.maisMeses(quantidadeParcelas - 1);

  bool ativaNoMes(Mes m) {
    final inicio = data.indice();
    final fim = data.indice() + quantidadeParcelas;
    return inicio <= m.indice() && m.indice() < fim;
  }

  int parcelaNoMes(Mes m) {
    final inicio = data.indice();
    if (m.indice() < inicio || m.indice() >= inicio + quantidadeParcelas) {
      return 0;
    }
    return m.indice() - inicio + 1;
  }

  bool pagaNoMes(Mes m) => pagasPorMes.contains(m.indice());

  List<Mes> get mesesAtivos {
    final inicio = data.indice();
    return List.generate(
        quantidadeParcelas, (i) => Mes.porIndice(inicio + i));
  }

  double get valorPendente =>
      valorIndividual * mesesAtivos.where((m) => !pagaNoMes(m)).length;

  bool get paga => mesesAtivos.every((m) => pagaNoMes(m));

  Compra copyWith({
    String? id,
    String? compradorId,
    String? bancoId,
    String? descricao,
    double? valorIndividual,
    int? quantidadeParcelas,
    Mes? data,
    Set<int>? pagasPorMes,
    String? iconeChave,
    String? iconeArquivo,
    String? origemFixaId,
  }) =>
      Compra(
        id: id ?? this.id,
        compradorId: compradorId ?? this.compradorId,
        bancoId: bancoId ?? this.bancoId,
        descricao: descricao ?? this.descricao,
        valorIndividual: valorIndividual ?? this.valorIndividual,
        quantidadeParcelas: quantidadeParcelas ?? this.quantidadeParcelas,
        data: data ?? this.data,
        pagasPorMes: pagasPorMes ?? this.pagasPorMes,
        iconeChave: iconeChave ?? this.iconeChave,
        iconeArquivo: iconeArquivo ?? this.iconeArquivo,
        origemFixaId: origemFixaId ?? this.origemFixaId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'compradorId': compradorId,
        'bancoId': bancoId,
        'descricao': descricao,
        'valorIndividual': valorIndividual,
        'quantidadeParcelas': quantidadeParcelas,
        'ano': data.ano,
        'mes': data.mes,
        'pagasPorMes': pagasPorMes.toList(),
        'paga': paga,
        if (iconeChave != null) 'iconeChave': iconeChave,
        if (iconeArquivo != null) 'iconeArquivo': iconeArquivo,
        if (origemFixaId != null) 'origemFixaId': origemFixaId,
      };

  factory Compra.fromJson(Map<String, dynamic> json) {
    Set<int> pagas = {};
    if (json['pagasPorMes'] != null) {
      pagas = (json['pagasPorMes'] as List).map((e) => e as int).toSet();
    } else if (json['paga'] as bool? ?? false) {
      final qtd = json['quantidadeParcelas'] as int? ?? 1;
      final ano = json['ano'] as int? ?? 0;
      final mes = json['mes'] as int? ?? 1;
      final inicio = Mes(ano, mes).indice();
      pagas = {for (var i = 0; i < qtd; i++) inicio + i};
    }
    return Compra(
      id: json['id'],
      compradorId: json['compradorId'],
      bancoId: json['bancoId'],
      descricao: json['descricao'],
      valorIndividual: (json['valorIndividual'] as num).toDouble(),
      quantidadeParcelas: json['quantidadeParcelas'],
      data: Mes(json['ano'], json['mes']),
      pagasPorMes: pagas,
      iconeChave: json['iconeChave'],
      iconeArquivo: json['iconeArquivo'],
      origemFixaId: json['origemFixaId'],
    );
  }
}
