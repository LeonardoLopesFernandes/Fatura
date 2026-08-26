import 'mes.dart';

class Compra {
  final String id;
  final String compradorId;
  final String bancoId;
  final String descricao;
  final double valorIndividual;
  final int quantidadeParcelas;
  final Mes data;

  Compra({
    required this.id,
    required this.compradorId,
    required this.bancoId,
    required this.descricao,
    required this.valorIndividual,
    required this.quantidadeParcelas,
    required this.data,
  });

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'compradorId': compradorId,
        'bancoId': bancoId,
        'descricao': descricao,
        'valorIndividual': valorIndividual,
        'quantidadeParcelas': quantidadeParcelas,
        'ano': data.ano,
        'mes': data.mes,
      };

  factory Compra.fromJson(Map<String, dynamic> json) => Compra(
        id: json['id'],
        compradorId: json['compradorId'],
        bancoId: json['bancoId'],
        descricao: json['descricao'],
        valorIndividual: (json['valorIndividual'] as num).toDouble(),
        quantidadeParcelas: json['quantidadeParcelas'],
        data: Mes(json['ano'], json['mes']),
      );
}
