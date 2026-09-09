import 'package:flutter/material.dart';
import '../../data/icones_compra.dart';
import '../../ui/tema.dart';

Future<String?> mostrarSeletorIcone(BuildContext context, String? atual) {
  return showDialog<String>(
    context: context,
    builder: (_) => _SeletorIconeDialog(atual: atual),
  );
}

class _SeletorIconeDialog extends StatefulWidget {
  final String? atual;
  const _SeletorIconeDialog({required this.atual});

  @override
  State<_SeletorIconeDialog> createState() => _SeletorIconeDialogState();
}

class _SeletorIconeDialogState extends State<_SeletorIconeDialog> {
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    final termo = _busca.trim().toLowerCase();
    final itens = termo.isEmpty
        ? IconesCompra.DISPONIVEIS
        : IconesCompra.DISPONIVEIS.where((item) =>
            (item['label'] as String).toLowerCase().contains(termo) ||
            (item['chave'] as String).toLowerCase().contains(termo)).toList();

    return AlertDialog(
      backgroundColor: Superficie,
      title: const Text('Escolher ícone',
          style: TextStyle(color: Branco)),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.55,
        child: Column(
          children: [
            TextField(
              onChanged: (v) => setState(() => _busca = v),
              style: const TextStyle(color: Branco, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Buscar ícone...',
                hintStyle: const TextStyle(color: Branco54, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Branco54),
                filled: true,
                fillColor: SuperficieElevada,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: itens.isEmpty
                  ? const Center(
                      child: Text('Nenhum ícone encontrado.',
                          style: TextStyle(color: Branco54)),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: itens.length,
                      itemBuilder: (_, i) {
                        final item = itens[i];
                        final selecionado =
                            item['chave'] == widget.atual;
                        return GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pop(item['chave'] as String),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: selecionado
                                      ? CorPrimaria
                                      : SuperficieElevada,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selecionado
                                        ? Branco
                                        : Branco.withOpacity(0.12),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  item['icone'] as IconData,
                                  color: Branco,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item['label'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: selecionado
                                      ? Branco
                                      : Branco54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child:
              const Text('Cancelar', style: TextStyle(color: Branco54)),
        ),
      ],
    );
  }
}
