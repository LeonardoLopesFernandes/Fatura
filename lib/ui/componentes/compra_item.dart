import 'package:flutter/material.dart';
import '../../models/banco.dart';
import '../../models/compra.dart';
import '../../ui/tema.dart';
import '../../ui/componentes/banco_logo.dart';
import '../../util/formatadores.dart';

class CompraItem extends StatelessWidget {
  final Compra compra;
  final Banco banco;
  final double? valorExibido;
  final String? rotuloParcelaCustom;
  final bool paga;
  final ValueChanged<bool>? onPagaChanged;
  final VoidCallback? onEdit;

  const CompraItem({
    super.key,
    required this.compra,
    required this.banco,
    this.valorExibido,
    this.rotuloParcelaCustom,
    this.paga = false,
    this.onPagaChanged,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cor = Color(banco.cor);
    final corTexto = contrastePara(banco.cor);
    final valor = valorExibido ?? compra.valorTotal;
    final rotulo =
        rotuloParcelaCustom ?? rotuloParcela(compra.quantidadeParcelas);

    Widget card() {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BancoLogo(banco: banco, tamanho: 40, raio: 10),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    compra.descricao,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: paga ? corTexto.withOpacity(0.6) : corTexto,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      decoration:
                          paga ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatarMoeda(compra.valorTotal),
                    style: TextStyle(
                      color: corTexto.withOpacity(0.9),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatarMoeda(valor),
                  style: TextStyle(
                    color: corTexto,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: Branco.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: Text(
                    rotulo.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      color: corTexto,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget corpo = card();
    if (onEdit != null) {
      corpo = GestureDetector(onLongPress: onEdit, child: corpo);
    }
    if (onPagaChanged != null) {
      corpo = Dismissible(
        key: Key(compra.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: Correto,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.only(right: 18),
          alignment: Alignment.centerRight,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.check_circle_outline, color: Branco),
              SizedBox(width: 6),
              Text('Paga',
                  style:
                      TextStyle(color: Branco, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        confirmDismiss: (_) async {
          onPagaChanged!(!paga);
          return false;
        },
        child: corpo,
      );
    }
    return corpo;
  }
}
