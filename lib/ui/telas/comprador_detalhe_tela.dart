import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/fatura_view_model.dart';
import '../../data/icones_compra.dart';
import '../../models/banco.dart';
import '../../models/compra.dart';
import '../../models/grupo.dart';
import '../../models/mes.dart';
import '../../ui/tema.dart';
import '../../ui/componentes/banco_logo.dart';
import '../../ui/componentes/compra_item.dart';
import '../../ui/componentes/elementos.dart';
import '../../ui/componentes/menu_compra.dart';
import '../../util/formatadores.dart';
import '../../compartilhar/gerar_imagem.dart';
import '../../compartilhar/gerar_pdf.dart';
import '../../compartilhar/compartilhar_arquivo.dart';

class CompradorDetalheScreen extends StatelessWidget {
  final String compradorId;
  final void Function(String) onAdicionarCompra;
  final VoidCallback onVoltar;

  const CompradorDetalheScreen({
    super.key,
    required this.compradorId,
    required this.onAdicionarCompra,
    required this.onVoltar,
  });

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FaturaViewModel>(context);
    final comprador = vm.compradorPorId(compradorId);

    if (comprador == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Text(
            'Devedor não encontrado.',
            style: TextStyle(color: Branco54, fontSize: 14),
          ),
        ),
      );
    }

    final mes = vm.mesSelecionado;
    final faturaBruta = vm.faturaDoCompradorBrutoNoMes(comprador.id, mes);
    final faturaRestante = vm.faturaDoCompradorNoMes(comprador.id, mes);
    final grupos =
        vm.agruparPorBanco(vm.comprasDoCompradorNoMes(comprador.id, mes));

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
        title: Text(
          comprador.nome,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Branco,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _mostrarCompartilhar(
                context, vm, comprador.nome, faturaBruta, grupos),
            icon: const Icon(Icons.share, color: Branco54),
          ),
          IconButton(
            onPressed: () => _confirmarApagar(context, vm, comprador.id),
            icon: const Icon(Icons.delete_outline, color: Branco54),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Superficie,
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CabecalhoMes(
                      mes,
                      () => vm.definirMesSelecionado(mes.maisMeses(-1)),
                      () => vm.definirMesSelecionado(mes.maisMeses(1)),
                    ),
                    const SizedBox(height: 12),
                    const Text('FATURA INDIVIDUAL',
                        style: TextStyle(
                          color: TituloAzul,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        )),
                    const SizedBox(height: 8),
                    Text(
                      formatarMoeda(faturaBruta),
                      style: const TextStyle(
                        color: Branco,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
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
                        Text(
                          formatarMoeda(faturaRestante),
                          style: const TextStyle(
                            color: Branco,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: vm.bancos.isEmpty
                            ? null
                            : () => onAdicionarCompra(comprador.nome),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CorPrimaria,
                          foregroundColor: Branco,
                          disabledForegroundColor: Branco54,
                          disabledBackgroundColor:
                              SuperficieElevada,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_shopping_cart),
                            SizedBox(width: 8),
                            Text('Nova Compra',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (grupos.isEmpty)
                      const Text(
                        'Nenhuma compra registrada para este devedor.',
                        style: TextStyle(color: Branco54, fontSize: 14),
                      )
                    else
                      ...grupos.map((grupo) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GrupoCard(
                            banco: grupo.banco,
                            compras: grupo.compras,
                            mes: mes,
                            onRemove: (compra) =>
                                vm.removerCompra(compra.id),
                            onPagaChanged: (compra, paga) =>
                                vm.marcarPaga(compra.id, mes, paga),
                            onEdit: (compra) => mostrarMenuCompra(
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarCompartilhar(
    BuildContext context,
    FaturaViewModel vm,
    String nome,
    double fatura,
    List<Grupo> grupos,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Superficie,
      isScrollControlled: true,
      builder: (_) => _PreviewCompartilhar(
        nome: nome,
        fatura: fatura,
        grupos: grupos,
        mes: vm.mesSelecionado,
      ),
    );
  }

  String _montarTexto(
      FaturaViewModel vm, String nome, double fatura, List<Grupo> grupos) {
    final buffer = StringBuffer();
    buffer.writeln('Fatura - $nome');
    buffer.writeln('Mês: ${rotuloMesLongo(vm.mesSelecionado)}');
    buffer.writeln('');
    if (grupos.isEmpty) {
      buffer.writeln('Nenhuma compra neste mês.');
    }
    for (final g in grupos) {
      buffer.writeln(g.banco.nome);
      for (final c in g.compras) {
        final parcela = c.quantidadeParcelas > 1
            ? ' (${c.quantidadeParcelas}x)'
            : '';
        final pago = c.paga ? ' [pago]' : '';
        buffer.writeln(
            '  - ${c.descricao}: ${formatarMoeda(c.valorTotal)}$parcela$pago');
      }
    }
    buffer.writeln('');
    buffer.writeln('Total: ${formatarMoeda(fatura)}');
    return buffer.toString();
  }

  String _montarCsv(FaturaViewModel vm, String nome, List<Grupo> grupos) {
    final buffer = StringBuffer();
    buffer.writeln('devedor,banco,descricao,valor,parcelas,data,paga');
    for (final g in grupos) {
      for (final c in g.compras) {
        final data =
            '${c.data.ano}-${c.data.mes.toString().padLeft(2, '0')}';
        buffer.writeln(
            '"${nome.replaceAll('"', "'")}",'
            '"${g.banco.nome.replaceAll('"', "'")}",'
            '"${c.descricao.replaceAll('"', "'")}",'
            '${c.valorTotal.toStringAsFixed(2).replaceAll('.', ',')},'
            '${c.quantidadeParcelas},'
            '$data,'
            '${c.paga ? 'sim' : 'nao'}');
      }
    }
    return buffer.toString();
  }

  void _confirmarApagar(
    BuildContext context,
    FaturaViewModel vm,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Superficie,
        title: const Text('Apagar devedor?',
            style: TextStyle(color: Branco)),
        content: Text(
          'Todas as compras de ${vm.compradorPorId(id)?.nome ?? ''} serão removidas.',
          style: TextStyle(color: Branco.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar',
                style: TextStyle(color: Branco54)),
          ),
          TextButton(
            onPressed: () {
              vm.removerComprador(id);
              Navigator.of(ctx).pop();
              onVoltar();
            },
            child: const Text('Apagar',
                style: TextStyle(color: VermelhoExcluir)),
          ),
        ],
      ),
    );
  }
}

class GrupoCard extends StatefulWidget {
  final Banco banco;
  final List<Compra> compras;
  final Mes mes;
  final void Function(Compra) onRemove;
  final void Function(Compra, bool) onPagaChanged;
  final void Function(Compra) onEdit;
  final bool initiallyExpanded;

  const GrupoCard({
    super.key,
    required this.banco,
    required this.compras,
    required this.mes,
    required this.onRemove,
    required this.onPagaChanged,
    required this.onEdit,
    this.initiallyExpanded = true,
  });

  @override
  State<GrupoCard> createState() => _GrupoCardState();
}

class _GrupoCardState extends State<GrupoCard> {
  late bool _expandido;

  @override
  void initState() {
    super.initState();
    _expandido = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final subtotal =
        widget.compras.fold(0.0, (s, c) => s + c.valorIndividual);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Superficie,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expandido = !_expandido),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  BancoLogo(banco: widget.banco, tamanho: 34, raio: 10),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.banco.nome,
                      style: const TextStyle(
                        color: Branco,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(widget.banco.cor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Text(
                      formatarMoeda(subtotal),
                      style: TextStyle(
                        color: contrastePara(widget.banco.cor),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expandido
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Branco54,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_expandido)
            ...widget.compras.map((compra) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CompraItem(
                  compra: compra,
                  banco: widget.banco,
                  paga: compra.pagaNoMes(widget.mes),
                  valorExibido: compra.valorIndividual,
                  rotuloParcelaCustom: compra.quantidadeParcelas > 1
                      ? 'Parcela ${compra.parcelaNoMes(widget.mes)} de ${compra.quantidadeParcelas}'
                                      : 'Mensal',
                  onPagaChanged: (paga) => widget.onPagaChanged(compra, paga),
                  onRemove: () => widget.onRemove(compra),
                  onEdit: () => widget.onEdit(compra),
                ),
              );
            }).toList(),
          if (_expandido) const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _PreviewCompartilhar extends StatefulWidget {
  final String nome;
  final double fatura;
  final List<Grupo> grupos;
  final Mes mes;

  const _PreviewCompartilhar({
    required this.nome,
    required this.fatura,
    required this.grupos,
    required this.mes,
  });

  @override
  State<_PreviewCompartilhar> createState() => _PreviewCompartilharState();
}

class _PreviewCompartilharState extends State<_PreviewCompartilhar> {
  final Set<String> _expandidos = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Preview da Fatura',
              style: TextStyle(
                  color: Branco, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(widget.nome,
              style: const TextStyle(color: Branco54, fontSize: 13)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('FATURA INDIVIDUAL',
                    style: TextStyle(
                      color: Color(0xFFA0B0C0),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    )),
                const SizedBox(height: 4),
                Text(
                  formatarMoeda(widget.fatura),
                  style: const TextStyle(
                    color: Branco,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...widget.grupos.map((grupo) {
            final subtotal = grupo.compras.fold(
                0.0, (s, c) => s + c.valorIndividual);
            final expandido = _expandidos.contains(grupo.banco.id);
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Color(grupo.banco.cor).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Color(grupo.banco.cor).withOpacity(0.5), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (expandido) {
                          _expandidos.remove(grupo.banco.id);
                        } else {
                          _expandidos.add(grupo.banco.id);
                        }
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              grupo.banco.nome.toUpperCase(),
                              style: const TextStyle(
                                color: Branco,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            formatarMoeda(subtotal),
                            style: const TextStyle(
                              color: Branco,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            expandido
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Branco54,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (expandido) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Column(
                        children: [
                          ...grupo.compras.map((compra) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      compra.iconeChave != null
                                          ? IconesCompra.iconePorChave(compra.iconeChave)
                                          : IconesCompra.iconePorDescricao(compra.descricao),
                                      color: Branco54,
                                      size: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      compra.descricao,
                                      style: const TextStyle(
                                        color: Color(0xFFE0E0E0),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    formatarMoeda(compra.valorIndividual),
                                    style: const TextStyle(
                                      color: Branco,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _mostrarOpcoes(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CorPrimaria,
                foregroundColor: Branco,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Compartilhar',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _mostrarOpcoes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Superficie,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Compartilhar como',
                style: TextStyle(
                    color: Branco,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.image, color: Branco),
              title: const Text('Imagem (PNG)',
                  style: TextStyle(color: Branco)),
              subtitle: const Text('Captura visual da fatura',
                  style: TextStyle(color: Branco54)),
              onTap: () async {
                Navigator.of(context).pop();
                final caminho = await gerarImagem(
                    nome: widget.nome, fatura: widget.fatura, grupos: widget.grupos);
                if (context.mounted) {
                  compartilharArquivo(
                      context, caminho, 'image/png', widget.nome);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Branco),
              title:
                  const Text('PDF', style: TextStyle(color: Branco)),
              subtitle: const Text('Documento formatado',
                  style: TextStyle(color: Branco54)),
              onTap: () async {
                Navigator.of(context).pop();
                final caminho = await gerarPdf(
                    nome: widget.nome, fatura: widget.fatura, grupos: widget.grupos);
                if (context.mounted) {
                  compartilharArquivo(
                      context, caminho, 'application/pdf', widget.nome);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_snippet, color: Branco),
              title:
                  const Text('Texto', style: TextStyle(color: Branco)),
              subtitle: const Text('Compartilhar como mensagem',
                  style: TextStyle(color: Branco54)),
              onTap: () {
                Navigator.of(context).pop();
                Share.share(
                  _montarTexto(),
                  subject: 'Fatura - ${widget.nome}',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Branco),
              title:
                  const Text('CSV', style: TextStyle(color: Branco)),
              subtitle: const Text('Planilha separada por vírgulas',
                  style: TextStyle(color: Branco54)),
              onTap: () async {
                Navigator.of(context).pop();
                try {
                  final dir = Directory(
                      '${(await getTemporaryDirectory()).path}/compartilhamento');
                  await dir.create(recursive: true);
                  final arquivo = File(
                      '${dir.path}/fatura_${limparNome(widget.nome)}.csv');
                  await arquivo.writeAsString(_montarCsv());
                  if (context.mounted) {
                    await Share.shareXFiles(
                      [XFile(arquivo.path, mimeType: 'text/csv')],
                      subject: 'Fatura - ${widget.nome}',
                    );
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Não foi possível gerar o CSV.')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _montarTexto() {
    final buffer = StringBuffer();
    buffer.writeln('Fatura - ${widget.nome}');
    buffer.writeln('');
    if (widget.grupos.isEmpty) {
      buffer.writeln('Nenhuma compra neste mês.');
    }
    for (final g in widget.grupos) {
      final subtotal =
          g.compras.fold(0.0, (s, c) => s + c.valorIndividual);
      buffer.writeln('${g.banco.nome} (${formatarMoeda(subtotal)}):');
      for (final c in g.compras) {
        buffer.writeln(
            '  - ${c.descricao}: ${formatarMoeda(c.valorIndividual)}');
      }
      buffer.writeln('');
    }
    buffer.writeln('Total: ${formatarMoeda(widget.fatura)}');
    return buffer.toString();
  }

  String _montarCsv() {
    final buffer = StringBuffer();
    buffer.writeln('banco,descricao,valor');
    for (final g in widget.grupos) {
      for (final c in g.compras) {
        buffer.writeln(
            '"${g.banco.nome.replaceAll('"', "'")}",'
            '"${c.descricao.replaceAll('"', "'")}",'
            '${c.valorIndividual.toStringAsFixed(2).replaceAll('.', ',')}');
      }
    }
    return buffer.toString();
  }
}
