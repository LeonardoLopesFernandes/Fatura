import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/banco.dart';
import '../../models/grupo.dart';
import '../../ui/tema.dart';
import '../../ui/temas.dart';
import '../../util/formatadores.dart';
import '../../util/pix.dart';

void cobrarTotalDevedor(
  BuildContext context, {
  required List<Grupo> grupos,
  required double valorTotal,
}) {
  final comChave = grupos
      .where((g) => (g.banco.chavePix?.trim() ?? '').isNotEmpty)
      .toList();
  if (comChave.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Cadastre a chave Pix na edição do banco.')),
    );
    return;
  }
  if (comChave.length == 1) {
    mostrarCobrancaPix(context,
        banco: comChave.first.banco, valor: valorTotal);
    return;
  }
  showModalBottomSheet(
    context: context,
    backgroundColor: context.cores.superficie,
    builder: (sheetContext) => Container(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Cobrar ${formatarMoeda(valorTotal)} via Pix. Qual chave usar?',
              style: TextStyle(
                  color: context.cores.texto, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...comChave.map((g) => ListTile(
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    g.banco.nome.trim().isNotEmpty
                        ? g.banco.nome.trim().substring(0, 1).toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Color(g.banco.cor),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(g.banco.nome,
                    style: TextStyle(color: context.cores.texto)),
                subtitle: Text(g.banco.chavePix!.trim(),
                    style: TextStyle(color: context.cores.textoSuave, fontSize: 12)),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  mostrarCobrancaPix(context,
                      banco: g.banco, valor: valorTotal);
                },
              )),
        ],
      ),
    ),
  );
}

void mostrarCobrancaPix(
  BuildContext context, {
  required Banco banco,
  required double valor,
}) {
  final chave = banco.chavePix?.trim() ?? '';
  if (chave.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Cadastre a chave Pix na edição do banco.')),
    );
    return;
  }
  final codigo = gerarPixCopiaECola(chave: chave, valor: valor);
  showModalBottomSheet(
    context: context,
    backgroundColor: context.cores.superficie,
    isScrollControlled: true,
    builder: (sheetContext) => Container(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 14,
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 14,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cobrar via Pix',
              style: TextStyle(
                  color: context.cores.texto, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(banco.nome.toUpperCase(),
              style: TextStyle(color: context.cores.textoSuave, fontSize: 13)),
          const SizedBox(height: 8),
          Text(
            formatarMoeda(valor),
            style: TextStyle(
              color: context.cores.texto,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.cores.superficieElevada,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SelectableText(
              codigo,
              style: TextStyle(color: context.cores.textoMedio, fontSize: 12),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: codigo));
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      const SnackBar(
                          content: Text('Código Pix copiado.')),
                    );
                  },
                  icon: Icon(Icons.copy, size: 18),
                  label: Text('Copiar código',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.cores.primaria,
                    foregroundColor: context.cores.texto,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Share.share(
                      'Pix ${banco.nome} ${formatarMoeda(valor)}\nChave: $chave\n```$codigo```',
                      subject: 'Cobrança Pix',
                    );
                  },
                  icon: Icon(Icons.share, size: 18),
                  label: Text('Enviar',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.cores.texto,
                    side: BorderSide(color: context.cores.texto.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
