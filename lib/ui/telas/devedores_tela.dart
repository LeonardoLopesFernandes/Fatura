import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../data/avatares.dart';
import '../../data/fatura_view_model.dart';
import '../../models/comprador.dart';
import '../../ui/tema.dart';
import '../../ui/temas.dart';
import '../../ui/componentes/avatar_devedor.dart';
import '../../ui/componentes/campo.dart';
import '../../util/formatadores.dart';

class NovoDevedorSheet extends StatefulWidget {
  const NovoDevedorSheet({super.key});

  @override
  State<NovoDevedorSheet> createState() => _NovoDevedorSheetState();
}

class _NovoDevedorSheetState extends State<NovoDevedorSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FaturaViewModel>(context, listen: false);
    return Container(
      color: context.cores.superficie,
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 14,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Novo Devedor',
              style: TextStyle(
                  color: context.cores.texto, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            style: TextStyle(color: context.cores.texto, fontSize: 16),
            decoration: campoCores('Nome do devedor',
                hint: 'Ex.: Carlos, Ana…'),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _confirmar(vm, context),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _confirmar(vm, context),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.cores.primaria,
                foregroundColor: context.cores.texto,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Adicionar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmar(FaturaViewModel vm, BuildContext context) {
    final nome = _controller.text.trim();
    if (nome.isEmpty) return;
    vm.adicionarComprador(nome);
    Navigator.of(context).pop();
  }
}

class DevedoresScreen extends StatefulWidget {
  final void Function(String) onAdicionarCompra;
  final void Function(String) onDetalharComprador;
  final VoidCallback onConfiguracoes;

  const DevedoresScreen({
    super.key,
    required this.onAdicionarCompra,
    required this.onDetalharComprador,
    required this.onConfiguracoes,
  });

  @override
  State<DevedoresScreen> createState() => _DevedoresScreenState();
}

class _DevedoresScreenState extends State<DevedoresScreen> {
  final _filtro = TextEditingController();

  @override
  void dispose() {
    _filtro.dispose();
    super.dispose();
  }

  Future<void> _escolherFoto(
      FaturaViewModel vm, Comprador comprador) async {
    try {
      final picker = ImagePicker();
      final imagem = await picker.pickImage(source: ImageSource.gallery);
      if (imagem == null) return;
      final dir = Directory(
          '${(await getApplicationDocumentsDirectory()).path}/avatares');
      await dir.create(recursive: true);
      final ext = imagem.path.split('.').last;
      final destino =
          '${dir.path}/avatar_${DateTime.now().microsecondsSinceEpoch}.$ext';
      await File(imagem.path).copy(destino);
      vm.atualizarComprador(comprador.id, avatarArquivo: destino);
    } catch (_) {}
  }

  void _mostrarAvatar(BuildContext context, FaturaViewModel vm,
      Comprador comprador) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cores.superficie,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Avatar de ${comprador.nome}',
                style: TextStyle(
                    color: context.cores.texto,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.of(sheetContext).pop();
                      await _escolherFoto(vm, comprador);
                    },
                    icon: Icon(Icons.photo_library,
                        color: context.cores.texto, size: 18),
                    label: Text('Galeria',
                        style: TextStyle(color: context.cores.texto)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: context.cores.texto.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      vm.atualizarComprador(comprador.id,
                          limparAvatar: true);
                    },
                    icon: Icon(Icons.delete_outline,
                        color: context.cores.perigoClaro, size: 18),
                    label: Text('Remover',
                        style: TextStyle(
                            color: context.cores.perigoClaro)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: context.cores.texto.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: Avatares.DISPONIVEIS.length,
              itemBuilder: (_, i) {
                final item = Avatares.DISPONIVEIS[i];
                final selecionado =
                    item['chave'] == comprador.avatarChave;
                return GestureDetector(
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    vm.atualizarComprador(comprador.id,
                        avatarChave: item['chave'] as String);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: selecionado
                              ? context.cores.primaria
                              : context.cores.superficieElevada,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selecionado
                                ? context.cores.texto
                                : context.cores.texto.withOpacity(0.12),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          item['icone'] as IconData,
                          color: context.cores.texto,
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
                              ? context.cores.texto
                              : context.cores.textoSuave,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FaturaViewModel>(context);
    final termo = _filtro.text.trim().toLowerCase();
    final compradores = termo.isEmpty
        ? vm.compradores
        : vm.compradores
            .where((c) => c.nome.toLowerCase().contains(termo))
            .toList();
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Devedores',
                        style: TextStyle(
                            color: context.cores.texto,
                            fontSize: 28,
                            fontWeight: FontWeight.w800)),
                  ),
                  IconButton(
                    onPressed: widget.onConfiguracoes,
                    icon: Icon(Icons.settings, color: context.cores.textoSuave),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Cadastre quem usa o cartão e consulte as faturas individuais.',
                style: TextStyle(color: context.cores.texto.withOpacity(0.6), fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _filtro,
                onChanged: (_) => setState(() {}),
                style: TextStyle(color: context.cores.texto, fontSize: 16),
                decoration: campoCores('', hint: 'Buscar devedor')
                    .copyWith(
                  prefixIcon:
                      Icon(Icons.search, color: context.cores.cinza),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: compradores.isEmpty
              ? Center(
                  child: Text(
                    vm.compradores.isEmpty
                        ? 'Nenhum devedor cadastrado.\nToque no botão abaixo.'
                        : 'Nenhum devedor encontrado.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: context.cores.texto.withOpacity(0.54), fontSize: 14),
                  ),
                )
              : ListView.separated(
                  padding:
                      const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 12),
                  itemCount: compradores.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final comprador = compradores[index];
                    final banco = vm.bancoPrincipalDoComprador(comprador.id);
                    final corBanco =
                        banco != null ? Color(banco.cor) : context.cores.primaria;
                    final fundo = Color.alphaBlend(
                        corBanco.withOpacity(0.4), context.cores.superficie);
                    final totalCompras =
                        vm.comprasDoComprador(comprador.id).length;
                    final fatura = vm.faturaDoComprador(comprador.id);
                    return GestureDetector(
                      onTap: () => widget.onAdicionarCompra(comprador.nome),
                      onLongPress: () =>
                          widget.onDetalharComprador(comprador.id),
                      child: Container(
                        decoration: BoxDecoration(
                          color: fundo,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  _mostrarAvatar(context, vm, comprador),
                              child: AvatarDevedor(
                                comprador: comprador,
                                tamanho: 48,
                                raio: 14,
                                corFundo: banco != null
                                    ? Color(banco.cor)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comprador.nome,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: context.cores.texto,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$totalCompras compra(s)${banco != null ? ' · ${banco.nome}' : ''}',
                                    style: TextStyle(
                                        color: context.cores.textoFraco, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: corBanco,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: Text(
                                formatarMoeda(fatura),
                                style: TextStyle(
                                  color: contrastePara(banco?.cor ??
                                      0xFF2563EB),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.chevron_right,
                                color: context.cores.texto.withOpacity(0.38)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                backgroundColor: context.cores.superficie,
                builder: (_) => const NovoDevedorSheet(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.cores.primaria,
                foregroundColor: context.cores.texto,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Novo Devedor',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
