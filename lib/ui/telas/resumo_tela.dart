import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/comprador.dart';
import '../../models/banco.dart';
import '../../models/compra.dart';
import '../../data/fatura_view_model.dart';
import '../../ui/tema.dart';
import '../../ui/componentes/elementos.dart';
import '../../ui/componentes/compra_item.dart';
import '../../ui/componentes/menu_compra.dart';
import '../../ui/componentes/carousel_bank_card.dart';
import '../../util/formatadores.dart';

class ResumoScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final vm = Provider.of<FaturaViewModel>(context);
    final mes = vm.mesSelecionado;
    final totalFaturas = vm.totalRestanteBancosNoMes(mes);
    final totalRestante = vm.totalCartaoNoMes(mes);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CabecalhoMes(
            mes,
            () => vm.definirMesSelecionado(mes.maisMeses(-1)),
            () => vm.definirMesSelecionado(mes.maisMeses(1)),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 6),
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
          const SizedBox(height: 12),
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
                    onTap: () => onEditarFaturaBanco(banco.id),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 20),
          if (vm.compradores.isEmpty)
            const MensagemVazia(
                'Nenhum devedor cadastrado.\nAdicione na aba Devedores.')
          else
            ...vm.compradores.map((comprador) {
              final faturaDoMes =
                  vm.faturaDoCompradorNoMes(comprador.id, mes);
              final comprasMes =
                  vm.comprasDoCompradorNoMes(comprador.id, mes);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Branco.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: Branco.withOpacity(0.1)),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => onAdicionarCompra(comprador.nome),
                        onLongPress: () => onDetalharComprador(comprador.id),
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
                      const Text(
                        'DETALHAMENTO',
                        style: TextStyle(
                          color: TituloAzul,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (comprasMes.isEmpty)
                        Text(
                          'Sem compras em ${rotuloMesLongo(mes)}.',
                          style: const TextStyle(
                            color: Branco54,
                            fontSize: 13,
                          ),
                        )
                      else
                        Column(
                          children: comprasMes.map((compra) {
                            final banco = vm.bancoPorId(compra.bancoId);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: CompraItem(
                                compra: compra,
                                banco: banco!,
                                paga: compra.pagaNoMes(mes),
                                valorExibido: compra.valorIndividual,
                                rotuloParcelaCustom:
                                    compra.quantidadeParcelas > 1
                                        ? 'Parcela ${compra.parcelaNoMes(mes)} de ${compra.quantidadeParcelas}'
                                        : 'Mensal',
                                onPagaChanged: (paga) =>
                                    vm.marcarPaga(compra.id, mes, paga),
                                onRemove: () => vm.removerCompra(compra.id),
                                onEdit: () => mostrarMenuCompra(
                                  context,
                                  compra,
                                  vm,
                                  jaPaga: compra.pagaNoMes(mes),
                                  onMarcarPaga: () => vm.marcarPaga(
                                      compra.id,
                                      mes,
                                      !compra.pagaNoMes(mes)),
                                ),
                              ),
                            );
                          }).toList(),
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
