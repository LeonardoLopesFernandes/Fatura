import 'package:flutter/material.dart';
import '../../data/fatura_view_model.dart';
import '../../models/compra.dart';
import '../../ui/tema.dart';
import '../../ui/componentes/editar_compra_dialog.dart';
import '../../util/formatadores.dart';

void mostrarMenuCompra(
  BuildContext context,
  Compra compra,
  FaturaViewModel vm, {
  required bool jaPaga,
  required VoidCallback onMarcarPaga,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Superficie,
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.edit, color: Branco),
          title: const Text('Editar', style: TextStyle(color: Branco)),
          onTap: () {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (_) => EditarCompraDialog(compra: compra),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.check_circle_outline, color: Correto),
          title: Text(
            jaPaga ? 'Marcar como não paga' : 'Marcar como paga',
            style: const TextStyle(color: Branco),
          ),
          onTap: () {
            Navigator.of(context).pop();
            onMarcarPaga();
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline, color: VermelhoExcluir),
          title: const Text('Excluir',
              style: TextStyle(color: VermelhoExcluir)),
          onTap: () {
            Navigator.of(context).pop();
            showDialog(
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
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancelar',
                        style: TextStyle(color: Branco54)),
                  ),
                  TextButton(
                    onPressed: () {
                      vm.removerCompra(compra.id);
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Excluir',
                        style: TextStyle(color: VermelhoExcluir)),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 6),
      ],
    ),
  );
}

void editarCompraAcesso(
  BuildContext context,
  Compra compra,
) {
  showDialog(
    context: context,
    builder: (_) => EditarCompraDialog(compra: compra),
  );
}
