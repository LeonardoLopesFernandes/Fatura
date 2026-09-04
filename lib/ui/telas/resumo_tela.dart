import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/comprador.dart';
import '../../models/banco.dart';
import '../../models/compra.dart';
import '../../models/grupo.dart';
import '../../data/fatura_view_model.dart';
import '../../ui/tema.dart';
import '../../ui/componentes/elementos.dart';
import '../../ui/componentes/compra_item.dart';
import '../../ui/componentes/banco_logo.dart';
import '../../ui/componentes/menu_compra.dart';
import '../../ui/componentes/carousel_bank_card.dart';
import '../../util/formatadores.dart';

class ResumoScreen extends StatefulWidget {
  final void Function(String?) onAdicionarCompra;
  final void Function(String) onDetalharComprador;
  final void Function(String) onEditarFaturaBanco;

  const ResumoScreen({
    super.key,
    required this.onAdicionarCompra,
    required this.onDetalharComprador,
    required this.onEditarFaturaBanco,
  });

  @override
  State<ResumoScreen> createState() => _ResumoScreenState();
}

class _ResumoScreenState extends State<ResumoScreen> {
  final Set<String> _expandidos = {};

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FaturaViewModel>(context);
    final mes = vm.mesSelecionado;
    final totalFaturas = vm.totalRestanteBancosNoMes(mes);
    final totalRestante = vm.totalCartaoNoMes(mes);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 8, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CabecalhoMes(
            mes,
            () => vm.definirMesSelecionado(mes.maisMeses(-1)),
            () => vm.definirMesSelecionado(mes.maisMeses(1)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const TituloSecao('Faturas no Cartão'),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: CorPrimaria,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: CorPrimaria.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  formatarMoeda(totalFaturas),
                  style: const TextStyle(
                    color: Branco,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                'Restante a receber',
                style: TextStyle(
                  color: Branco54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: CorPrimaria.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  formatarMoeda(totalRestante),
                  style: const TextStyle(
                    color: Branco,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (vm.bancos.isEmpty)
            const MensagemVazia('Nenhum banco cadastrado.')
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 10,
                children: vm.bancos.map((banco) {
                  final informada =
                      vm.faturaInformadaDoBancoNoMes(banco.id, mes);
                  final devedores =
                      vm.faturaDoBancoBrutoNoMes(banco.id, mes);
                  final devedoresPendentes =
                      vm.faturaDoBancoNoMes(banco.id, mes);
                  final saldo = informada > 0
                      ? (informada - devedores)
                      : devedores;
                  final restante = informada > 0
                      ? (informada - devedores)
                      : devedoresPendentes;
                  return CarouselBankCard(
                    banco: banco,
                    saldo: saldo,
                    restante: restante,
                    faturaInformada: informada,
                    onTap: () => widget.onEditarFaturaBanco(banco.id),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 14),
          if (vm.compradores.isEmpty)
            const MensagemVazia(
                'Nenhum devedor cadastrado.\nAdicione na aba Devedores.')
          else
            ...vm.compradores.map((comprador) {
              final faturaDoMes =
                  vm.faturaDoCompradorNoMes(comprador.id, mes);
              final comprasMes =
                  vm.comprasDoCompradorNoMes(comprador.id, mes);
              final grupos = vm.agruparPorBanco(comprasMes);
              final expandido = _expandidos.contains(comprador.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Branco.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: Branco.withOpacity(0.1)),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => widget.onAdicionarCompra(comprador.nome),
                        onLongPress: () => widget.onDetalharComprador(comprador.id),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                comprador.nome.toUpperCase(),
                                style: const TextStyle(
                                  color: Branco,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Correto,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text(
                                formatarMoeda(faturaDoMes),
                                style: const TextStyle(
                                  color: Branco,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (grupos.isNotEmpty)
                        ...grupos.map((grupo) {
                          final subtotal = grupo.compras.fold(
                              0.0, (s, c) => s + c.valorIndividual);
                          final grupoExpandido =
                              _expandidos.contains('${comprador.id}_${grupo.banco.id}');
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: Color(grupo.banco.cor).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Color(grupo.banco.cor).withOpacity(0.3),
                                  width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      final chave = '${comprador.id}_${grupo.banco.id}';
                                      if (grupoExpandido) {
                                        _expandidos.remove(chave);
                                      } else {
                                        _expandidos.add(chave);
                                      }
                                    });
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    child: Row(
                                      children: [
                                        BancoLogo(
                                            banco: grupo.banco,
                                            tamanho: 22,
                                            raio: 6),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            grupo.banco.nome.toUpperCase(),
                                            style: const TextStyle(
                                              color: Branco,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          grupoExpandido
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: Branco54,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Color(grupo.banco.cor).withOpacity(0.35),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      formatarMoeda(subtotal),
                                      style: const TextStyle(
                                        color: Branco,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                if (grupoExpandido)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 0, 10, 6),
                                    child: Column(
                                      children: [
                                        ...grupo.compras.map((compra) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8),
                                            child: CompraItem(
                                              compra: compra,
                                              banco: grupo.banco,
                                              paga: compra.pagaNoMes(mes),
                                              valorExibido:
                                                  compra.valorIndividual,
                                              rotuloParcelaCustom:
                                                  compra.quantidadeParcelas > 1
                                                      ? 'Parcela ${compra.parcelaNoMes(mes)} de ${compra.quantidadeParcelas}'
                                                      : 'Mensal',
                                              onPagaChanged: (paga) => vm
                                                  .marcarPaga(
                                                      compra.id, mes, paga),
                                              onRemove: () =>
                                                  vm.removerCompra(compra.id),
                                              onEdit: () => mostrarMenuCompra(
                                                context,
                                                compra,
                                                vm,
                                                jaPaga:
                                                    compra.pagaNoMes(mes),
                                                onMarcarPaga: () =>
                                                    vm.marcarPaga(
                                                        compra.id,
                                                        mes,
                                                        !compra.pagaNoMes(
                                                            mes)),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      if (grupos.isEmpty)
                        Text(
                          'Sem compras em ${rotuloMesLongo(mes)}.',
                          style: const TextStyle(
                            color: Branco54,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
