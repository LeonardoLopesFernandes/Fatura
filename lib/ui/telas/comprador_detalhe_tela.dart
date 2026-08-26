import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/fatura_view_model.dart';
import '../../models/banco.dart';
import '../../models/compra.dart';
import '../../models/grupo.dart';
import '../../ui/tema.dart';
import '../../ui/componentes/banco_logo.dart';
import '../../ui/componentes/compra_item.dart';
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

    final fatura = vm.faturaDoComprador(comprador.id);
    final grupos = vm.agruparPorBanco(vm.comprasDoComprador(comprador.id));

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
                context, vm, comprador.nome, fatura, grupos),
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
                    const Text('FATURA INDIVIDUAL',
                        style: TextStyle(
                          color: TituloAzul,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        )),
                    const SizedBox(height: 8),
                    Text(
                      formatarMoeda(fatura),
                      style: const TextStyle(
                        color: CorPrimaria,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
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
                            onRemove: (compra) =>
                                vm.removerCompra(compra.id),
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
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Compartilhar como',
                style: TextStyle(
                    color: Branco, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading:
                  const Icon(Icons.image, color: Branco),
              title: const Text('Imagem (PNG)',
                  style: TextStyle(color: Branco)),
              subtitle: const Text('Captura da tela do devedor',
                  style: TextStyle(color: Branco54)),
              onTap: () async {
                Navigator.of(context).pop();
                final caminho = await gerarImagem(
                    nome: nome, fatura: fatura, grupos: grupos);
                if (context.mounted) {
                  compartilharArquivo(
                      context, caminho, 'image/png', nome);
                }
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.picture_as_pdf, color: Branco),
              title:
                  const Text('PDF', style: TextStyle(color: Branco)),
              subtitle: const Text('Resumo das compras em texto',
                  style: TextStyle(color: Branco54)),
              onTap: () async {
                Navigator.of(context).pop();
                final caminho = await gerarPdf(
                    nome: nome, fatura: fatura, grupos: grupos);
                if (context.mounted) {
                  compartilharArquivo(
                      context, caminho, 'application/pdf', nome);
                }
              },
            ),
          ],
        ),
      ),
    );
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

class GrupoCard extends StatelessWidget {
  final Banco banco;
  final List<Compra> compras;
  final void Function(Compra) onRemove;

  const GrupoCard({
    super.key,
    required this.banco,
    required this.compras,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal =
        compras.fold(0.0, (s, c) => s + c.valorTotal);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Superficie,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                BancoLogo(banco: banco, tamanho: 34, raio: 10),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    banco.nome,
                    style: const TextStyle(
                      color: Branco,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Color(banco.cor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(
                    formatarMoeda(subtotal),
                    style: TextStyle(
                      color: contrastePara(banco.cor),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...compras.map((compra) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CompraItem(
                compra: compra,
                banco: banco,
                onRemove: () => onRemove(compra),
              ),
            );
          }).toList(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
