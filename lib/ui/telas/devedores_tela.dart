import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/fatura_view_model.dart';
import '../../ui/tema.dart';
import '../../ui/componentes/banco_logo.dart';
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
      color: Superficie,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Novo Devedor',
              style: TextStyle(
                  color: Branco, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            style: const TextStyle(color: Branco, fontSize: 16),
            decoration: campoCores('Nome do devedor',
                hint: 'Ex.: Carlos, Ana…',
                prefixIcon: const Text('👤',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20))),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _confirmar(vm, context),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _confirmar(vm, context),
              style: ElevatedButton.styleFrom(
                backgroundColor: CorPrimaria,
                foregroundColor: Branco,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Adicionar',
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

class DevedoresScreen extends StatelessWidget {
  final void Function(String) onAdicionarCompra;
  final void Function(String) onDetalharComprador;

  const DevedoresScreen({
    super.key,
    required this.onAdicionarCompra,
    required this.onDetalharComprador,
  });

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FaturaViewModel>(context);
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Devedores',
                  style: TextStyle(
                      color: Branco,
                      fontSize: 28,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                'Cadastre quem usa o cartão e consulte as faturas individuais.',
                style: TextStyle(color: Branco.withOpacity(0.6), fontSize: 14),
              ),
            ],
          ),
        ),
        Expanded(
          child: vm.compradores.isEmpty
              ? Center(
                  child: Text(
                    'Nenhum devedor cadastrado.\nToque no botão abaixo.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Branco.withOpacity(0.54), fontSize: 14),
                  ),
                )
              : ListView.separated(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 16),
                  itemCount: vm.compradores.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final comprador = vm.compradores[index];
                    final banco = vm.bancoPrincipalDoComprador(comprador.id);
                    final corBanco =
                        banco != null ? Color(banco.cor) : CorPrimaria;
                    final fundo = Color.alphaBlend(
                        corBanco.withOpacity(0.4), Superficie);
                    final totalCompras =
                        vm.comprasDoComprador(comprador.id).length;
                    final fatura = vm.faturaDoComprador(comprador.id);
                    return GestureDetector(
                      onTap: () => onAdicionarCompra(comprador.nome),
                      onLongPress: () =>
                          onDetalharComprador(comprador.id),
                      child: Container(
                        decoration: BoxDecoration(
                          color: fundo,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            if (banco != null)
                              BancoLogo(
                                  banco: banco, tamanho: 48, raio: 14)
                            else
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: CorPrimaria,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.person,
                                    color: Branco, size: 26),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comprador.nome,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      color: Branco,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$totalCompras compra(s)${banco != null ? ' · ${banco.nome}' : ''}',
                                    style: TextStyle(
                                        color: Branco38, fontSize: 12),
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
                                color: Branco.withOpacity(0.38)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                backgroundColor: Superficie,
                builder: (_) => const NovoDevedorSheet(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: CorPrimaria,
                foregroundColor: Branco,
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
