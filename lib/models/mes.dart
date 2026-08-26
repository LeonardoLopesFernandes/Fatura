class Mes implements Comparable<Mes> {
  final int ano;
  final int mes;

  Mes(this.ano, this.mes) : assert(mes >= 1 && mes <= 12);

  Mes maisMeses(int n) {
    final total = (ano * 12 + (mes - 1)) + n;
    return Mes(total ~/ 12, (total % 12) + 1);
  }

  int indice() => ano * 12 + (mes - 1);

  @override
  int compareTo(Mes other) => indice().compareTo(other.indice());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mes && other.ano == ano && other.mes == mes;

  @override
  int get hashCode => ano * 100 + mes;

  @override
  String toString() => '$ano-${mes.toString().padLeft(2, '0')}';
}
