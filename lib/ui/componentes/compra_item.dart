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
  final VoidCallback? onRemove;
  final ValueChanged<bool>? onPagaChanged;
  final VoidCallback? onEdit;

  const CompraItem({
    super.key,
    required this.compra,
    required this.banco,
    this.valorExibido,
    this.rotuloParcelaCustom,
    this.paga = false,
    this.onRemove,
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

    Widget check() {
      if (onPagaChanged == null) return const SizedBox.shrink();
      return GestureDetector(
        onTap: () => onPagaChanged!(!paga),
        child: Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: paga ? Correto : Branco.withOpacity(0.16),
            border: paga
                ? null
                : Border.all(color: Branco54, width: 1.5),
          ),
          child: Icon(
            paga ? Icons.check : Icons.circle,
            size: 14,
            color: paga ? Branco : Colors.transparent,
          ),
        ),
      );
    }

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
            check(),
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
                      color: paga
                          ? corTexto.withOpacity(0.6)
                          : corTexto,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      decoration: paga
                          ? TextDecoration.lineThrough
                          : null,
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

    Widget child;
    if (onRemove == null) {
      child = card();
    } else {
      child = Dismissible(
        key: Key(compra.id),
        direction: DismissDirection.startToEnd,
        background: Container(
          decoration: BoxDecoration(
            color: LacunaVermelha,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.only(left: 18),
          alignment: Alignment.centerLeft,
          child: const Row(
            children: [
              Icon(Icons.delete_outline, color: Branco),
              SizedBox(width: 6),
              Text('Excluir',
                  style: TextStyle(color: Branco, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
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
        },
        child: card(),
      );
    }

    if (onEdit != null) {
      child = GestureDetector(onLongPress: onEdit, child: child);
    }
    return child;
  }
}
