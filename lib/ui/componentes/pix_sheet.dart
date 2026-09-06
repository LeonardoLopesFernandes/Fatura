import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/banco.dart';
import '../../ui/tema.dart';
import '../../util/formatadores.dart';
import '../../util/pix.dart';

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
    backgroundColor: Superficie,
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
          const Text('Cobrar via Pix',
              style: TextStyle(
                  color: Branco, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(banco.nome.toUpperCase(),
              style: const TextStyle(color: Branco54, fontSize: 13)),
          const SizedBox(height: 8),
          Text(
            formatarMoeda(valor),
            style: const TextStyle(
              color: Branco,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SuperficieElevada,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SelectableText(
              codigo,
              style: const TextStyle(color: Branco70, fontSize: 12),
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
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copiar código',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CorPrimaria,
                    foregroundColor: Branco,
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
                      'Pix ${banco.nome} ${formatarMoeda(valor)}:\n$codigo',
                      subject: 'Cobrança Pix',
                    );
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Enviar',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Branco,
                    side: BorderSide(color: Branco.withOpacity(0.3)),
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
