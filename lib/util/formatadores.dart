import 'dart:math';
import '../models/mes.dart';

const List<String> MESES = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

String nomeMes(int mes) => MESES[mes - 1];

String nomeMesCurto(int mes) =>
    MESES[mes - 1].substring(0, 3).toUpperCase();

String formatarMoedaAbrev(double valor) {
  if (valor >= 1000) {
    final k = valor / 1000;
    final texto = k >= 100
        ? k.toStringAsFixed(0)
        : k.toStringAsFixed(1).replaceAll('.', ',');
    return 'R\$ ${texto}k';
  }
  return formatarMoeda(valor);
}

String rotuloMes(Mes data) =>
    '${nomeMes(data.mes).toUpperCase()} ${data.ano % 100}';

String rotuloMesLongo(Mes data) => '${nomeMes(data.mes)} ${data.ano}';

String rotuloParcela(int qtd) =>
    qtd == 1 ? 'Mensal' : 'Parcela 1 de $qtd';

Mes hojeMes() {
  final agora = DateTime.now();
  return Mes(agora.year, agora.month);
}

List<Mes> ultimosMeses(int n, Mes aPartirDe) {
  final lista = <Mes>[];
  for (int i = 0; i < n; i++) {
    lista.add(aPartirDe.maisMeses(-i));
  }
  return lista;
}

String formatarMoeda(double valor) {
  final negativo = valor < 0;
  final absoluto = negativo ? -valor : valor;
  final formatado = absoluto.toStringAsFixed(2);
  final partes = formatado.split('.');
  final inteiro = partes[0];
  final decimal = partes[1];

  final caracteres = inteiro.split('');
  final agrupado = <String>[];
  for (int i = 0; i < caracteres.length; i++) {
    if (i > 0 && (caracteres.length - i) % 3 == 0) {
      agrupado.add('.');
    }
    agrupado.add(caracteres[i]);
  }
  final inteiroAgrupado = agrupado.join('');
  final resultado = 'R\$ $inteiroAgrupado,$decimal';
  return negativo ? '-$resultado' : resultado;
}

double valorDeEntradaBr(String texto) {
  final digitos = texto.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitos.isEmpty) return 0.0;
  final valor = int.tryParse(digitos) ?? 0;
  return valor / 100.0;
}

String limparNome(String nome) =>
    nome.replaceAll(RegExp(r'[^\w.\-]'), '_');
