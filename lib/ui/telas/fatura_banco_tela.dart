import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/fatura_view_model.dart';
import '../../models/mes.dart';
import '../../models/banco.dart';
import '../../ui/tema.dart';
import '../../ui/temas.dart';
import '../../ui/componentes/banco_logo.dart';
import '../../ui/componentes/campo.dart';
import '../../util/formatadores.dart';
import '../../util/currency_input_formatter.dart';

class FaturaBancoScreen extends StatefulWidget {
  final String bancoId;
  final Mes mes;
  final VoidCallback onVoltar;

  const FaturaBancoScreen({
    super.key,
    required this.bancoId,
    required this.mes,
    required this.onVoltar,
  });

  @override
  State<FaturaBancoScreen> createState() => _FaturaBancoScreenState();
}

class _FaturaBancoScreenState extends State<FaturaBancoScreen> {
  final _valor = TextEditingController();
  final _focoValor = FocusNode();

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<FaturaViewModel>(context, listen: false);
    final faturaAtual =
        vm.faturaInformadaDoBancoNoMes(widget.bancoId, widget.mes);
    _valor.text = faturaAtual > 0 ? formatarMoeda(faturaAtual) : '';
  }

  @override
  void dispose() {
    _valor.dispose();
    _focoValor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FaturaViewModel>(context);
    final banco = vm.bancoPorId(widget.bancoId);

    if (banco == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onVoltar());
      return Scaffold(backgroundColor: context.cores.gradienteA);
    }

    final faturaAtual =
        vm.faturaInformadaDoBancoNoMes(widget.bancoId, widget.mes);
    final devedores =
        vm.faturaDoBancoBrutoNoMes(widget.bancoId, widget.mes);
    final devedoresPendentes =
        vm.faturaDoBancoNoMes(widget.bancoId, widget.mes);
    final restante = faturaAtual > 0
        ? (faturaAtual - devedores)
        : devedoresPendentes;

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
        title: Text('Fatura do ${banco.nome}',
            style: TextStyle(
                color: context.cores.texto, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            Campo(
              'Valor total da fatura (R\$)',
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
              hint: 'R\$ 0,00',
              focusNode: _focoValor,
            ),
            const SizedBox(height: 8),
            Text(
              'Compras dos devedores no mês: ${formatarMoeda(devedores)}',
              style: TextStyle(color: context.cores.textoSuave, fontSize: 12),
            ),
            if (faturaAtual > 0)
              Text(
                'Restante para completar a fatura: ${formatarMoeda(restante)}',
                style: TextStyle(
                    color: context.cores.sucesso, fontSize: 13, fontWeight: FontWeight.bold),
              )
            else
              Text(
                'Restante a receber dos devedores: ${formatarMoeda(restante)}',
                style: TextStyle(color: context.cores.textoSuave, fontSize: 12),
              ),
            if (faturaAtual > 0)
              Text(
                'Fatura informada: ${formatarMoeda(faturaAtual)}',
                style: TextStyle(color: context.cores.texto.withOpacity(0.38), fontSize: 12),
              ),
            const SizedBox(height: 4),
            if (faturaAtual > 0)
              TextButton(
                onPressed: () {
                  vm.definirFaturaDoBancoNoMes(
                      widget.bancoId, widget.mes, 0.0);
                  widget.onVoltar();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete, color: context.cores.texto, size: 18),
                    SizedBox(width: 6),
                    Text('Limpar fatura',
                        style: TextStyle(color: context.cores.texto)),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final v = valorDeEntradaBr(_valor.text);
                  if (v <= 0) return;
                  vm.definirFaturaDoBancoNoMes(
                      widget.bancoId, widget.mes, v);
                  widget.onVoltar();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.cores.primaria,
                  foregroundColor: context.cores.texto,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Salvar Fatura',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
