import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/comprador.dart';
import '../../models/banco.dart';
import '../../models/compra.dart';
import '../../models/grupo.dart';
import '../../data/fatura_view_model.dart';
import '../../ui/tema.dart';
import '../../ui/componentes/elementos.dart';
import '../../ui/componentes/campo.dart';
import '../../ui/componentes/compra_item.dart';
import '../../ui/componentes/banco_logo.dart';
import '../../ui/componentes/menu_compra.dart';
import '../../ui/componentes/pix_sheet.dart';
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
  final Map<String, Set<String>> _selecao = {};
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FaturaViewModel>(context);
    final mes = vm.mesSelecionado;
    final totalFaturas = vm.totalRestanteBancosNoMes(mes);
    final totalRestante = vm.totalCartaoNoMes(mes);
    final termo = _busca.trim().toLowerCase();
    final comMovimento = vm.compradores
        .where((c) => vm.comprasDoCompradorNoMes(c.id, mes).isNotEmpty)
        .toList();
    final listaFiltrada = termo.isEmpty
        ? comMovimento
        : comMovimento.where((c) {
            if (c.nome.toLowerCase().contains(termo)) return true;
            return vm.comprasDoCompradorNoMes(c.id, mes).any((cp) {
              final b = vm.bancoPorId(cp.bancoId);
              return cp.descricao.toLowerCase().contains(termo) ||
                  (b?.nome.toLowerCase().contains(termo) ?? false);
            });
          }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CabecalhoMes(
            mes,
            () => vm.definirMesSelecionado(mes.maisMeses(-1)),
            () => vm.definirMesSelecionado(mes.maisMeses(1)),
          ),
          const SizedBox(height: 8),
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
                  color: Branco,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  formatarMoeda(totalRestante),
                  style: const TextStyle(
                    color: VermelhoBotao,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            onChanged: (v) => setState(() => _busca = v),
            style: const TextStyle(color: Branco, fontSize: 15),
            decoration: campoCores('', hint: 'Buscar devedor ou compra')
                .copyWith(
              prefixIcon: const Icon(Icons.search, color: CinzaClaro),
            ),
          ),
          const SizedBox(height: 6),
          if (vm.bancos.isEmpty)
            const MensagemVazia('Nenhum banco cadastrado.')
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 8,
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
          const SizedBox(height: 10),
          if (vm.compradores.isEmpty)
            const MensagemVazia(
                'Nenhum devedor cadastrado.\nAdicione na aba Devedores.')
          else if (listaFiltrada.isEmpty)
            MensagemVazia(termo.isEmpty
                ? 'Sem compras em ${rotuloMesLongo(mes)}.'
                : 'Nada encontrado para "$_busca".')
          else
            ...listaFiltrada.map((comprador) {
              final faturaDoMes =
                  vm.faturaDoCompradorNoMes(comprador.id, mes);
              final comprasMes =
                  vm.comprasDoCompradorNoMes(comprador.id, mes);
              final grupos = vm.agruparPorBanco(comprasMes);
              final expandido = _expandidos.contains(comprador.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Branco.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: Branco.withOpacity(0.1)),
                  ),
                  padding: const EdgeInsets.all(8),
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
                            IconButton(
                              onPressed: () => cobrarTotalDevedor(
                                context,
                                grupos: grupos,
                                valorTotal:
                                    vm.faturaDoCompradorBrutoNoMes(
                                        comprador.id, mes),
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.pix,
                                color: Branco54,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: Correto,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
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
          const SizedBox(height: 6),
                      if (grupos.isNotEmpty)
                        ...grupos.map((grupo) {
                          final qtd = grupo.compras.length;
                          final subtotal = grupo.compras.fold(
                              0.0, (s, c) => s + c.valorIndividual);
                          final todasPagas = grupo.compras.isNotEmpty &&
                              grupo.compras
                                  .every((c) => c.pagaNoMes(mes));
                          final grupoExpandido = termo.isNotEmpty
                              ? true
                              : _expandidos.contains(
                                  '${comprador.id}_${grupo.banco.id}');
                          final chaveGrupo =
                              '${comprador.id}_${grupo.banco.id}';
                          final selecionando =
                              _selecao.containsKey(chaveGrupo);
                          final marcados =
                              _selecao[chaveGrupo] ?? <String>{};
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 4),
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
                                        horizontal: 8, vertical: 4),
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
                                        if (todasPagas)
                                          Container(
                                            width: 22,
                                            height: 22,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Correto,
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              color: Branco,
                                              size: 14,
                                            ),
                                          ),
                                        const SizedBox(width: 6),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              if (selecionando) {
                                                _selecao.remove(chaveGrupo);
                                              } else {
                                                _selecao[chaveGrupo] =
                                                    <String>{};
                                                _expandidos.add(chaveGrupo);
                                              }
                                            });
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints:
                                              const BoxConstraints(),
                                          icon: Icon(
                                            selecionando
                                                ? Icons.check_box
                                                : Icons
                                                    .check_box_outline_blank,
                                            color: selecionando
                                                ? CorPrimaria
                                                : Branco54,
                                            size: 18,
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              formatarMoeda(subtotal),
                                              style: const TextStyle(
                                                color: Branco,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (!grupoExpandido)
                                              Text(
                                                '$qtd compra${qtd != 1 ? 's' : ''}',
                                                style: const TextStyle(
                                                  color: Branco54,
                                                  fontSize: 10,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(width: 4),
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
                                if (grupoExpandido)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        8, 0, 8, 4),
                                    child: Column(
                                      children: [
                                        ...grupo.compras.map((compra) {
                                          final item = CompraItem(
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
                                          );
                                          if (!selecionando) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.only(
                                                      bottom: 6),
                                              child: item,
                                            );
                                          }
                                          final marcado =
                                              marcados.contains(compra.id);
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 6),
                                            child: Row(
                                              children: [
                                                Checkbox(
                                                  value: marcado,
                                                  activeColor: CorPrimaria,
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  onChanged: (v) {
                                                    setState(() {
                                                      if (v == true) {
                                                        _selecao[chaveGrupo]!
                                                            .add(compra.id);
                                                      } else {
                                                        _selecao[chaveGrupo]!
                                                            .remove(compra.id);
                                                      }
                                                    });
                                                  },
                                                ),
                                                Expanded(child: item),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        if (selecionando &&
                                            marcados.isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 2),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '${marcados.length} selecionada(s)',
                                                  style: const TextStyle(
                                                    color: Branco54,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                const Spacer(),
                                                TextButton(
                                                  onPressed: () {
                                                    vm.marcarPagas(
                                                        marcados, mes, true);
                                                    setState(() => _selecao
                                                        .remove(chaveGrupo));
                                                  },
                                                  child: const Text(
                                                      'Marcar pagas',
                                                      style: TextStyle(
                                                          color:
                                                              CorPrimaria)),
                                                ),
                                                TextButton(
                                                  onPressed: () => setState(
                                                      () => _selecao.remove(
                                                          chaveGrupo)),
                                                  child: const Text('Limpar',
                                                      style: TextStyle(
                                                          color: Branco54)),
                                                ),
                                              ],
                                            ),
                                          ),
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
