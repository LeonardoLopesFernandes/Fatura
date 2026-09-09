import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/fatura_view_model.dart';
import '../../data/icones_compra.dart';
import '../../models/compra.dart';
import '../../models/mes.dart';
import '../../ui/tema.dart';
import '../../ui/temas.dart';
import '../../ui/componentes/banco_logo.dart';
import '../../ui/componentes/campo.dart';
import '../../ui/componentes/seletor_icone_dialog.dart';
import '../../util/formatadores.dart';
import '../../util/currency_input_formatter.dart';

class EditarCompraDialog extends StatefulWidget {
  final Compra compra;
  const EditarCompraDialog({super.key, required this.compra});

  @override
  State<EditarCompraDialog> createState() => _EditarCompraDialogState();
}

class _EditarCompraDialogState extends State<EditarCompraDialog> {
  late final TextEditingController _descricao;
  late final TextEditingController _valor;
  late final TextEditingController _parcelas;
  late final FocusNode _focoDescricao;
  late final FocusNode _focoValor;
  late final FocusNode _focoParcelas;
  late String? _bancoId;
  late String? _iconeChave;
  late Mes _mes;

  @override
  void initState() {
    super.initState();
    final c = widget.compra;
    _descricao = TextEditingController(text: c.descricao);
    _valor = TextEditingController(
      text: formatarMoeda(c.valorTotal)
          .replaceAll('R\$', '')
          .replaceAll(' ', ''),
    );
    _parcelas = TextEditingController(text: c.quantidadeParcelas.toString());
    _bancoId = c.bancoId;
    _iconeChave = c.iconeChave;
    _mes = c.data;
    _focoDescricao = FocusNode();
    _focoValor = FocusNode();
    _focoParcelas = FocusNode();
  }

  @override
  void dispose() {
    _descricao.dispose();
    _valor.dispose();
    _parcelas.dispose();
    _focoDescricao.dispose();
    _focoValor.dispose();
    _focoParcelas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FaturaViewModel>(context);
    final meses = ultimosMeses(24, _mes);
    final bancoValido = vm.bancos.any((b) => b.id == _bancoId);
    if (_bancoId == null && vm.bancos.isNotEmpty) {
      _bancoId = vm.bancos.last.id;
    }

    return AlertDialog(
      backgroundColor: context.cores.superficie,
      title: Text('Editar compra',
          style: TextStyle(color: context.cores.texto)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Campo(
              'Descrição',
              TextField(
                controller: _descricao,
                focusNode: _focoDescricao,
                style: TextStyle(color: context.cores.texto, fontSize: 16),
                textCapitalization: TextCapitalization.sentences,
                decoration: campoCores(''),
              ),
              hint: 'Nome da compra',
              focusNode: _focoDescricao,
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
            Campo(
              'Cartão do lançamento',
              vm.bancos.isEmpty
                  ? Text('Cadastre um banco primeiro.',
                      style: TextStyle(color: context.cores.textoSuave, fontSize: 13))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 8,
                        children: vm.bancos.map((banco) {
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
                        }).toList(),
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
                        onTap: () => setState(
                            () => _iconeChave = item['chave'] as String),
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
                  final chave =
                      await mostrarSeletorIcone(context, _iconeChave);
                  if (chave != null) {
                    setState(() => _iconeChave = chave);
                  }
                },
                icon: Icon(Icons.grid_view,
                    color: context.cores.azulClaro, size: 16),
                label: Text('Ver todos',
                    style:
                        TextStyle(color: context.cores.azulClaro, fontSize: 13)),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child:
              Text('Cancelar', style: TextStyle(color: context.cores.textoSuave)),
        ),
        TextButton(
          onPressed: vm.bancos.isEmpty || !bancoValido
              ? null
              : () {
                  final v = valorDeEntradaBr(_valor.text);
                  final p = int.tryParse(_parcelas.text) ?? 0;
                  if (_descricao.text.trim().isEmpty ||
                      v <= 0 ||
                      p < 1 ||
                      _bancoId == null) {
                    return;
                  }
                  vm.editarCompra(
                    widget.compra.id,
                    descricao: _descricao.text.trim(),
                    valorIndividual: v / p,
                    quantidadeParcelas: p,
                    bancoId: _bancoId!,
                    data: _mes,
                    iconeChave: _iconeChave,
                  );
                  Navigator.of(context).pop();
                },
          child: Text('Salvar',
              style: TextStyle(color: context.cores.azulClaro)),
        ),
      ],
    );
  }
}
