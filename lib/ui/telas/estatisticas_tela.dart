import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/fatura_view_model.dart';
import '../../models/mes.dart';
import '../../ui/tema.dart';
import '../../ui/componentes/elementos.dart';
import '../../util/formatadores.dart';

class EstatisticasScreen extends StatelessWidget {
  final VoidCallback onVoltar;

  const EstatisticasScreen({super.key, required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FaturaViewModel>(context);
    final mes = vm.mesSelecionado;
    final meses = List.generate(6, (i) => mes.maisMeses(i - 5));
    final totais = [
      for (final m in meses) vm.totalFaturasBrutoNoMes(m)
    ];
    final maximo = totais.fold(0.0, (a, b) => a > b ? a : b);

    final brutoMes = vm.totalFaturasBrutoNoMes(mes);
    final pendenteMes = vm.totalCartaoNoMes(mes);
    final pagoMes = brutoMes - pendenteMes;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: FundoInicio,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: onVoltar,
          icon: const Icon(Icons.arrow_back, color: Branco),
        ),
        title: const Text('Estatísticas',
            style: TextStyle(
                color: Branco, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CabecalhoMes(
              mes,
              () => vm.definirMesSelecionado(mes.maisMeses(-1)),
              () => vm.definirMesSelecionado(mes.maisMeses(1)),
            ),
            const SizedBox(height: 10),
            const TituloSecao('Últimos 6 meses'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Branco.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Branco.withOpacity(0.1)),
              ),
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                height: 150,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < meses.length; i++)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              formatarMoedaAbrev(totais[i]),
                              maxLines: 1,
                              style: const TextStyle(
                                color: Branco54,
                                fontSize: 9,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              height: maximo <= 0
                                  ? 4
                                  : 4 + 90 * (totais[i] / maximo),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 5),
                              decoration: BoxDecoration(
                                color: meses[i] == mes
                                    ? CorPrimaria
                                    : Branco.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              nomeMesCurto(meses[i].mes),
                              style: TextStyle(
                                color: meses[i] == mes
                                    ? Branco
                                    : Branco54,
                                fontSize: 10,
                                fontWeight: meses[i] == mes
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const TituloSecao('Situação do mês'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _CartaoNumero(
                      'Total', formatarMoeda(brutoMes), CorPrimaria),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CartaoNumero(
                      'Pago', formatarMoeda(pagoMes), Correto),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CartaoNumero('A receber',
                      formatarMoeda(pendenteMes), VermelhoBotao),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const TituloSecao('Por banco no mês'),
            const SizedBox(height: 8),
            if (vm.bancos.isEmpty)
              const MensagemVazia('Nenhum banco cadastrado.')
            else
              ...vm.bancos.map((banco) {
                final total = vm.faturaDoBancoBrutoNoMes(banco.id, mes);
                final fracao =
                    brutoMes <= 0 ? 0.0 : (total / brutoMes).clamp(0.0, 1.0);
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: Color(banco.cor).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Color(banco.cor).withOpacity(0.3)),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              banco.nome.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Branco,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            formatarMoeda(total),
                            style: const TextStyle(
                              color: Branco,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: fracao,
                          minHeight: 7,
                          backgroundColor: Branco.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(banco.cor)),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _CartaoNumero extends StatelessWidget {
  final String rotulo;
  final String valor;
  final Color cor;

  const _CartaoNumero(this.rotulo, this.valor, this.cor);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Branco.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Branco.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo,
              style: const TextStyle(color: Branco54, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: cor,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
