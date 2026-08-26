import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/fatura_view_model.dart';
import '../../models/mes.dart';
import '../../models/banco.dart';
import '../../ui/tema.dart';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FaturaViewModel>(context);
    final banco = vm.bancoPorId(widget.bancoId);

    if (banco == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onVoltar());
      return const Scaffold(backgroundColor: FundoInicio);
    }

    final faturaAtual =
        vm.faturaInformadaDoBancoNoMes(widget.bancoId, widget.mes);
    final comprasMes =
        vm.totalComprasDoBancoNoMes(widget.bancoId, widget.mes);
    final saldo = vm.saldoDoBancoNoMes(widget.bancoId, widget.mes);

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
        title: Text('Fatura do ${banco.nome}',
            style: const TextStyle(
                color: Branco, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Campo(
              'Valor total da fatura (R\$)',
              TextField(
                controller: _valor,
                style: const TextStyle(color: Branco, fontSize: 16),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  BrazilianCurrencyInputFormatter(),
                ],
                decoration: campoCores('',
                    hint: 'R\$ 0,00'),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Compras do mês: ${formatarMoeda(comprasMes)} · saldo: ${formatarMoeda(saldo)}',
              style: const TextStyle(color: Branco54, fontSize: 12),
            ),
            if (faturaAtual > 0)
              Text(
                'Fatura atual informada: ${formatarMoeda(faturaAtual)}',
                style: TextStyle(color: Branco.withOpacity(0.38), fontSize: 12),
              ),
            const SizedBox(height: 4),
            if (faturaAtual > 0)
              TextButton(
                onPressed: () {
                  vm.definirFaturaDoBancoNoMes(
                      widget.bancoId, widget.mes, 0.0);
                  widget.onVoltar();
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete, color: Branco, size: 18),
                    SizedBox(width: 6),
                    Text('Limpar fatura',
                        style: TextStyle(color: Branco)),
                  ],
                ),
              ),
            const SizedBox(height: 12),
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
                  backgroundColor: CorPrimaria,
                  foregroundColor: Branco,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Salvar Fatura',
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
