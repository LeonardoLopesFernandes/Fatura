import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/fatura_view_model.dart';
import '../../data/open_finance.dart';
import '../../models/banco.dart';
import '../../models/mes.dart';
import '../../ui/tema.dart';
import '../../ui/temas.dart';
import '../../util/formatadores.dart';

class OpenFinanceScreen extends StatefulWidget {
  const OpenFinanceScreen({super.key});

  @override
  State<OpenFinanceScreen> createState() => _OpenFinanceScreenState();
}

class _OpenFinanceScreenState extends State<OpenFinanceScreen> {
  late final OpenFinanceService _service = criarOpenFinanceService();
  bool _carregando = true;
  String? _erro;
  List<OpenFinanceInvoice> _faturas = [];

  @override
  void initState() {
    super.initState();
    _sincronizar();
  }

  Future<void> _sincronizar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final faturas = await _service.fetchInvoices();
      if (!mounted) return;
      setState(() {
        _faturas = faturas;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.toString().replaceFirst('Exception: ', '');
        _carregando = false;
      });
    }
  }

  String _normalizar(String texto) =>
      texto.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  Banco? _bancoPara(FaturaViewModel vm, String nome) {
    final alvo = _normalizar(nome);
    if (alvo.isEmpty) return null;
    for (final banco in vm.bancos) {
      final atual = _normalizar(banco.nome);
      if (atual.isEmpty) continue;
      if (atual == alvo || atual.contains(alvo) || alvo.contains(atual)) {
        return banco;
      }
    }
    return null;
  }

  Future<void> _aplicar() async {
    if (openFinanceUsandoMock) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: context.cores.superficie,
          title: Text('Aplicar dados simulados?',
              style: TextStyle(color: context.cores.texto)),
          content: Text(
            'As faturas exibidas são apenas do POC e não vêm dos bancos. '
            'Aplicar mesmo assim?',
            style: TextStyle(color: context.cores.textoSuave),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Cancelar',
                  style: TextStyle(color: context.cores.textoSuave)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('Aplicar',
                  style: TextStyle(color: context.cores.primaria)),
            ),
          ],
        ),
      );
      if (confirmar != true || !mounted) return;
    }

    final vm = Provider.of<FaturaViewModel>(context, listen: false);
    final totais = <String, double>{};
    final meses = <String, Mes>{};
    final bancos = <String, Banco>{};
    var aplicadas = 0;
    var semBanco = 0;

    for (final fatura in _faturas) {
      final banco = _bancoPara(vm, fatura.institutionName);
      if (banco == null) {
        semBanco++;
        continue;
      }
      final mes = fatura.mesFatura;
      final chave = '${banco.id}|${mes.indice()}';
      totais[chave] = (totais[chave] ?? 0) + fatura.total;
      meses[chave] = mes;
      bancos[chave] = banco;
      aplicadas++;
    }

    for (final chave in totais.keys) {
      final banco = bancos[chave]!;
      vm.definirFaturaDoBancoNoMes(banco.id, meses[chave]!, totais[chave]!);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$aplicadas fatura(s) aplicada(s)'
          '${semBanco > 0 ? ' · $semBanco sem banco correspondente' : ''}.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FaturaViewModel>(context);
    final usandoMock = openFinanceUsandoMock;
    final encontradas = _faturas
        .where((f) => _bancoPara(vm, f.institutionName) != null)
        .length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: context.cores.gradienteA,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: context.cores.textoSuave),
        ),
        title: Text(
          'Open Finance (POC)',
          style: TextStyle(
            color: context.cores.texto,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _carregando ? null : _sincronizar,
            icon: Icon(Icons.refresh, color: context.cores.primaria),
          ),
        ],
      ),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
              ),
              child: Text(
                usandoMock
                    ? 'POC com dados simulados. Para usar o backend Pluggy, '
                        'compile com --dart-define=OPEN_FINANCE_API=https://seu-backend.'
                    : 'POC conectado ao backend: $openFinanceApiBase',
                style: TextStyle(
                  color: context.cores.texto,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Mês aberto no app: ${rotuloMesLongo(vm.mesSelecionado)}',
              style: TextStyle(
                color: context.cores.textoSuave,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'As faturas serão aplicadas no mês de vencimento de cada uma.',
              style: TextStyle(
                color: context.cores.textoSuave,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            if (_carregando)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(
                    color: context.cores.primaria,
                  ),
                ),
              )
            else if (_erro != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.cores.superficie,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      _erro!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.cores.perigo),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: _sincronizar,
                      child: const Text('TENTAR NOVAMENTE'),
                    ),
                  ],
                ),
              )
            else if (_faturas.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(
                    'Nenhuma fatura encontrada.',
                    style: TextStyle(color: context.cores.textoSuave),
                  ),
                ),
              )
            else ...[
              for (final fatura in _faturas) _card(vm, fatura),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: encontradas == 0 ? null : _aplicar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.cores.primaria,
                    foregroundColor: context.cores.texto,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'APLICAR $encontradas FATURA(S) AOS BANCOS',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _card(FaturaViewModel vm, OpenFinanceInvoice fatura) {
    final banco = _bancoPara(vm, fatura.institutionName);
    final cor = banco != null ? Color(banco.cor) : context.cores.textoSuave;
    final vence = fatura.dueDate;
    final data =
        '${vence.day.toString().padLeft(2, '0')}/${vence.month.toString().padLeft(2, '0')}/${vence.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cores.superficie,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: cor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.credit_card, color: cor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fatura.institutionName,
                  style: TextStyle(
                    color: context.cores.texto,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${rotuloMesLongo(fatura.mesFatura)} · vence $data'
                  '${fatura.cardLast4 != null ? ' · final ${fatura.cardLast4}' : ''}',
                  style: TextStyle(
                    color: context.cores.textoSuave,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  banco == null
                      ? 'Sem banco correspondente no app'
                      : 'Aplicar em ${banco.nome}',
                  style: TextStyle(
                    color: banco == null
                        ? context.cores.perigo
                        : context.cores.sucesso,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatarMoeda(fatura.total),
            style: TextStyle(
              color: context.cores.texto,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
