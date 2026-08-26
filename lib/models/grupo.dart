import 'banco.dart';
import 'compra.dart';

class Grupo {
  final Banco banco;
  final List<Compra> compras;

  Grupo(this.banco, this.compras);

  double get subtotal =>
      compras.fold(0.0, (soma, c) => soma + c.valorTotal);
}
