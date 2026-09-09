import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/fatura_view_model.dart';
import '../../data/icones_compra.dart';
import '../../models/mes.dart';
import '../../ui/tema.dart';
import '../../ui/temas.dart';
import '../../ui/componentes/banco_logo.dart';
import '../../ui/componentes/campo.dart';
import '../../ui/componentes/seletor_icone_dialog.dart';
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
  final _focoDescricao = FocusNode();
  final _focoDevedor = FocusNode();
  final _focoValor = FocusNode();
  final _focoParcelas = FocusNode();
  String? _bancoId;
  String? _iconeChave;
  bool _iconeManual = false;
  late Mes _mes;
  String? _aviso;
  bool _fixa = false;

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
    _focoDescricao.dispose();
    _focoDevedor.dispose();
    _focoValor.dispose();
    _focoParcelas.dispose();
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
        backgroundColor: context.cores.gradienteA,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: widget.onVoltar,
          icon: Icon(Icons.close, color: context.cores.textoSuave),
        ),
        title: Text('Nova Compra',
            style: TextStyle(color: context.cores.texto, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Campo(
                    'Descrição',
                    TextField(
                      controller: _descricao,
                      focusNode: _focoDescricao,
                      style: TextStyle(color: context.cores.texto, fontSize: 16),
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: campoCores(''),
                      onChanged: (v) {
                        if (_iconeManual) return;
                        final auto = IconesCompra.chavePorDescricao(v);
                        if (auto != _iconeChave) {
                          setState(() => _iconeChave = auto);
                        }
                      },
                    ),
                    hint: 'Nome da compra',
                    focusNode: _focoDescricao,
                  ),
                  const SizedBox(height: 10),
                  Campo(
                    'Nome do devedor',
                    TextField(
                      controller: _devedor,
                      focusNode: _focoDevedor,
                      style: TextStyle(color: context.cores.texto, fontSize: 16),
                      textCapitalization: TextCapitalization.words,
                      decoration: campoCores(''),
                    ),
                    hint: 'Quem pagou esta compra',
                    focusNode: _focoDevedor,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Campo(
                          'Valor (R\$)',
                          TextField(
                            controller: _valor,
                            focusNode: _focoValor,
                            style: TextStyle(color: context.cores.texto, fontSize: 16),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              BrazilianCurrencyInputFormatter(),
                            ],
                            decoration: campoCores(''),
                          ),
                          hint: 'Valor',
                          focusNode: _focoValor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Campo(
                          'Parcelas',
                          TextField(
                            controller: _parcelas,
                            focusNode: _focoParcelas,
                            enabled: !_fixa,
                            style: TextStyle(color: context.cores.texto, fontSize: 16),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: campoCores(''),
                          ),
                          hint: 'Parcela',
                          focusNode: _focoParcelas,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: context.cores.superficieElevada,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      title: Text('Repetir todo mês',
                          style: TextStyle(
                              color: context.cores.texto,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          'Conta fixa: lança sozinha nos próximos meses',
                          style:
                              TextStyle(color: context.cores.textoSuave, fontSize: 12)),
                      value: _fixa,
                      activeTrackColor: context.cores.sucesso,
                      activeColor: Colors.white,
                      onChanged: (v) => setState(() => _fixa = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Campo(
                    'Cartão do lançamento',
                    vm.bancos.isEmpty
                        ? Text('Cadastre um banco primeiro.',
                            style: TextStyle(color: context.cores.textoSuave, fontSize: 13))
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
                                            : context.cores.superficieElevada,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: selecionado
                                              ? context.cores.texto
                                              : context.cores.texto.withOpacity(0.12),
                                          width: 1.5,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
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
                                                  : context.cores.texto,
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
                                      color: context.cores.superficieElevada,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: context.cores.texto.withOpacity(0.12),
                                        width: 1.5,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: Center(
                                            child: Icon(Icons.add,
                                                color: context.cores.texto,
                                                size: 20),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text('Novo',
                                            style: TextStyle(
                                                color: context.cores.texto,
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
                  const SizedBox(height: 10),
                  Campo(
                    'Ícone da compra',
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 6,
                        children: [
                          ...IconesCompra.DISPONIVEIS.map((item) {
                            final selecionado = item['chave'] == _iconeChave;
                            return GestureDetector(
                              onTap: () => setState(() {
                                _iconeChave = item['chave'] as String;
                                _iconeManual = true;
                              }),
                              child: SizedBox(
                                width: 60,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: selecionado
                                            ? context.cores.primaria
                                            : context.cores.superficieElevada,
                                        borderRadius:
                                            BorderRadius.circular(10),
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
                                        size: 20,
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
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () async {
                        final chave = await mostrarSeletorIcone(
                            context, _iconeChave);
                        if (chave != null) {
                          setState(() {
                            _iconeChave = chave;
                            _iconeManual = true;
                          });
                        }
                      },
                        icon: Icon(Icons.grid_view,
                            color: context.cores.azulClaro, size: 16),
                        label: Text('Ver todos',
                            style: TextStyle(
                                color: context.cores.azulClaro, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Campo(
                    'Mês de referência',
                    DropdownButtonFormField<Mes>(
                      value: _mes,
                      items: meses.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(rotuloMesLongo(m),
                              style: TextStyle(color: context.cores.texto)),
                        );
                      }).toList(),
                      onChanged: (m) => setState(() => _mes = m!),
                      dropdownColor: context.cores.superficieElevada,
                      decoration: campoCores(''),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                        onPressed: vm.bancos.isEmpty
                            ? null
                            : () {
                                final v = valorDeEntradaBr(_valor.text);
                                final p = _fixa
                                    ? 1
                                    : (int.tryParse(_parcelas.text) ?? 0);
                                if (_descricao.text.trim().isEmpty ||
                                    _devedor.text.trim().isEmpty ||
                                    v <= 0 ||
                                    (!_fixa && p < 1) ||
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
                                valorIndividual: v / p,
                                quantidadeParcelas: p,
                                data: _mes,
                                iconeChave: _iconeChave,
                                fixaMensal: _fixa,
                              );
                              if (_devedor.text.trim().toLowerCase() !=
                                  (widget.nomePadrao?.trim().toLowerCase())) {
                                setState(() => _aviso =
                                    'Compra lançada para ${comprador.nome}.');
                              }
                              widget.onVoltar();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.cores.primaria,
                        foregroundColor: context.cores.texto,
                        disabledForegroundColor: context.cores.textoSuave,
                        disabledBackgroundColor: context.cores.superficieElevada,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Salvar Compra',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (_aviso != null) ...[
                    const SizedBox(height: 8),
                    Text(_aviso!,
                        style:
                            TextStyle(color: context.cores.textoMedio, fontSize: 13)),
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
