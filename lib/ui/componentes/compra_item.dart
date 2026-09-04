import 'package:flutter/material.dart';
import '../../models/banco.dart';
import '../../models/compra.dart';
import '../../data/icones_compra.dart';
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
  final VoidCallback? onRemove;
  final VoidCallback? onEdit;

  const CompraItem({
    super.key,
    required this.compra,
    required this.banco,
    this.valorExibido,
    this.rotuloParcelaCustom,
    this.paga = false,
    this.onPagaChanged,
    this.onRemove,
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Branco.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                compra.iconeChave != null
                    ? IconesCompra.iconePorChave(compra.iconeChave)
                    : IconesCompra.iconePorDescricao(compra.descricao),
                color: contrastePara(banco.cor),
                size: 20,
              ),
            ),
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

    final podePaga = onPagaChanged != null;
    final podeRemover = onRemove != null;

    if (podePaga || podeRemover) {
      corpo = Dismissible(
        key: Key(compra.id),
        direction: DismissDirection.horizontal,
        background: podeRemover
            ? Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: LacunaVermelha,
                      ),
                      child: const Icon(Icons.delete_outline,
                          color: Branco, size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Text('Excluir',
                        style: TextStyle(
                            color: Branco, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            : Container(),
        secondaryBackground: podePaga
            ? Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Paga',
                        style: TextStyle(
                            color: Branco, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Correto,
                      ),
                      child: const Icon(Icons.check_circle_outline,
                          color: Branco, size: 22),
                    ),
                  ],
                ),
              )
            : Container(),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            if (!podeRemover) return false;
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: Superficie,
                title: const Text('Excluir compra?',
                    style: TextStyle(color: Branco)),
                content: Text(
                  '${compra.descricao}\n${formatarMoeda(compra.valorTotal)} será removida da fatura.',
                  style: TextStyle(color: Branco.withOpacity(0.7)),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text('Cancelar',
                        style: TextStyle(color: Branco.withOpacity(0.7))),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Excluir',
                        style: TextStyle(color: VermelhoExcluir)),
                  ),
                ],
              ),
            );
            if (ok == true) {
              onRemove!();
              return true;
            }
            return false;
          } else {
            if (!podePaga) return false;
            onPagaChanged!(!paga);
            return false;
          }
        },
        child: corpo,
      );
    }
    return corpo;
  }
}
