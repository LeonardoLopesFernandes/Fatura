import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/fatura_view_model.dart';
import '../../models/mes.dart';
import '../../ui/tema.dart';
import '../../ui/componentes/banco_logo.dart';
import '../../ui/componentes/campo.dart';
import '../../util/formatadores.dart';
import '../../util/currency_input_formatter.dart';

class NovaCompraScreen extends StatefulWidget {
  final String? nomePadrao;
  final VoidCallback onNovoBanco;
  final VoidCallback onVoltar;

  const NovaCompraScreen({
    super.key,
    this.nomePadrao,
    required this.onNovoBanco,
    required this.onVoltar,
  });

  @override
  State<NovaCompraScreen> createState() => _NovaCompraScreenState();
}

class _NovaCompraScreenState extends State<NovaCompraScreen> {
  final _descricao = TextEditingController();
  final _devedor = TextEditingController();
  final _valor = TextEditingController();
  final _parcelas = TextEditingController();
  String? _bancoId;
  late Mes _mes;
  String? _aviso;

  @override
  void initState() {
    super.initState();
    _devedor.text = widget.nomePadrao ?? '';
    _mes = hojeMes();
    final vm = Provider.of<FaturaViewModel>(context, listen: false);
    _bancoId = vm.bancos.firstOrNull?.id;
  }

  @override
  void dispose() {
    _descricao.dispose();
    _devedor.dispose();
    _valor.dispose();
    _parcelas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FaturaViewModel>(context);
    final meses = ultimosMeses(24, _mes);

    if (_bancoId == null && vm.bancos.isNotEmpty) {
      _bancoId = vm.bancos.last.id;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: FundoInicio,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: widget.onVoltar,
          icon: const Icon(Icons.close, color: Branco54),
        ),
        title: const Text('Nova Compra',
            style: TextStyle(color: Branco, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Campo(
                    'Descrição',
                    TextField(
                      controller: _descricao,
                      style: const TextStyle(color: Branco, fontSize: 16),
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: campoCores('',
                          hint: 'Nome da compra',
                          prefixIcon: const Text('🧾',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18))),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Campo(
                    'Nome do devedor',
                    TextField(
                      controller: _devedor,
                      style: const TextStyle(color: Branco, fontSize: 16),
                      textCapitalization: TextCapitalization.words,
                      decoration: campoCores('',
                          hint: 'Quem pagou esta compra',
                          prefixIcon: const Text('👤',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18))),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Campo(
                          'Valor individual (R\$)',
                          TextField(
                            controller: _valor,
                            style: const TextStyle(color: Branco, fontSize: 16),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              BrazilianCurrencyInputFormatter(),
                            ],
                            decoration: campoCores('',
                                hint: 'R\$ 0,00',
                                prefixIcon: const Text('💲',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 18))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Campo(
                          'Parcelas',
                          TextField(
                            controller: _parcelas,
                            style: const TextStyle(color: Branco, fontSize: 16),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: campoCores('',
                                hint: '1',
                                prefixIcon: const Text('📅',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 18))),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Campo(
                    'Cartão do lançamento',
                    vm.bancos.isEmpty
                        ? const Text('Cadastre um banco primeiro.',
                            style: TextStyle(color: Branco54, fontSize: 13))
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              spacing: 8,
                              children: [
                                ...vm.bancos.map((banco) {
                                  final selecionado = banco.id == _bancoId;
                                  return GestureDetector(
                                    onTap: () =>
                                        setState(() => _bancoId = banco.id),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: selecionado
                                            ? Color(banco.cor)
                                            : SuperficieElevada,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: selecionado
                                              ? Branco
                                              : Branco.withOpacity(0.12),
                                          width: 1.5,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      child: Row(
                                        children: [
                                          BancoLogo(
                                              banco: banco,
                                              tamanho: 30,
                                              raio: 8),
                                          const SizedBox(width: 8),
                                          Text(
                                            banco.nome,
                                            style: TextStyle(
                                              color: selecionado
                                                  ? contrastePara(banco.cor)
                                                  : Branco,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                                GestureDetector(
                                  onTap: widget.onNovoBanco,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: SuperficieElevada,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Branco.withOpacity(0.12),
                                        width: 1.5,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.add,
                                            color: Branco, size: 20),
                                        SizedBox(width: 6),
                                        Text('Novo',
                                            style: TextStyle(
                                                color: Branco,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 14),
                  Campo(
                    'Mês de referência',
                    DropdownButtonFormField<Mes>(
                      value: _mes,
                      items: meses.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(rotuloMesLongo(m),
                              style: const TextStyle(color: Branco)),
                        );
                      }).toList(),
                      onChanged: (m) => setState(() => _mes = m!),
                      dropdownColor: SuperficieElevada,
                      decoration: campoCores(''),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: vm.bancos.isEmpty
                          ? null
                          : () {
                              final v = valorDeEntradaBr(_valor.text);
                              final p = int.tryParse(_parcelas.text) ?? 0;
                              if (_descricao.text.trim().isEmpty ||
                                  _devedor.text.trim().isEmpty ||
                                  v <= 0 ||
                                  p < 1 ||
                                  _bancoId == null) {
                                setState(() => _aviso =
                                    'Preencha descrição, nome do devedor, valor e parcelas.');
                                return;
                              }
                              final comprador = vm.obterOuCriarComprador(
                                  nome: _devedor.text.trim());
                              vm.adicionarCompra(
                                compradorId: comprador.id,
                                bancoId: _bancoId!,
                                descricao: _descricao.text.trim(),
                                valorIndividual: v,
                                quantidadeParcelas: p,
                                data: _mes,
                              );
                              if (_devedor.text.trim().toLowerCase() !=
                                  (widget.nomePadrao?.trim().toLowerCase())) {
                                setState(() => _aviso =
                                    'Compra lançada para ${comprador.nome}.');
                              }
                              widget.onVoltar();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CorPrimaria,
                        foregroundColor: Branco,
                        disabledForegroundColor: Branco54,
                        disabledBackgroundColor: SuperficieElevada,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Salvar Compra',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (_aviso != null) ...[
                    const SizedBox(height: 12),
                    Text(_aviso!,
                        style:
                            TextStyle(color: Branco70, fontSize: 13)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
