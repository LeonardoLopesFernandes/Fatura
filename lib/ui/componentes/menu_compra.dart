import 'package:flutter/material.dart';
import '../../data/fatura_view_model.dart';
import '../../models/compra.dart';
import '../../ui/tema.dart';
import '../../ui/temas.dart';
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
    backgroundColor: context.cores.superficie,
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.edit, color: context.cores.texto),
          title: Text('Editar', style: TextStyle(color: context.cores.texto)),
          onTap: () {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (_) => EditarCompraDialog(compra: compra),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.check_circle_outline, color: context.cores.sucesso),
          title: Text(
            jaPaga ? 'Marcar como não paga' : 'Marcar como paga',
            style: TextStyle(color: context.cores.texto),
          ),
          onTap: () {
            Navigator.of(context).pop();
            onMarcarPaga();
          },
        ),
        ListTile(
          leading: Icon(Icons.delete_outline, color: context.cores.perigoClaro),
          title: Text('Excluir',
              style: TextStyle(color: context.cores.perigoClaro)),
          onTap: () {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: context.cores.superficie,
                title: Text('Excluir compra?',
                    style: TextStyle(color: context.cores.texto)),
                content: Text(
                  '${compra.descricao}\n${formatarMoeda(compra.valorTotal)} será removida da fatura.',
                  style: TextStyle(color: context.cores.texto.withOpacity(0.7)),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text('Cancelar',
                        style: TextStyle(color: context.cores.textoSuave)),
                  ),
                  TextButton(
                    onPressed: () {
                      vm.removerCompra(compra.id);
                      Navigator.of(ctx).pop();
                    },
                    child: Text('Excluir',
                        style: TextStyle(color: context.cores.perigoClaro)),
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
