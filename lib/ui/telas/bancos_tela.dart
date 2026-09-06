import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/fatura_view_model.dart';
import '../../models/banco.dart';
import '../../ui/tema.dart';
import '../../ui/componentes/banco_logo.dart';
import '../../util/formatadores.dart';

class BancosScreen extends StatelessWidget {
  final VoidCallback onNovoBanco;
  final void Function(String) onEditarBanco;
  final VoidCallback onConfiguracoes;

  const BancosScreen({
    super.key,
    required this.onNovoBanco,
    required this.onEditarBanco,
    required this.onConfiguracoes,
  });

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FaturaViewModel>(context);
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Bancos',
                        style: TextStyle(
                            color: Branco,
                            fontSize: 28,
                            fontWeight: FontWeight.w800)),
                  ),
                  IconButton(
                    onPressed: onConfiguracoes,
                    icon: const Icon(Icons.settings, color: Branco54),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Cada banco possui cor e ícone exclusivos, sem repetições.',
                style: TextStyle(color: Branco.withOpacity(0.6), fontSize: 14),
              ),
            ],
          ),
        ),
        Expanded(
          child: vm.bancos.isEmpty
              ? Center(
                  child: Text(
                    'Nenhum banco cadastrado.\nAdicione um novo banco.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Branco.withOpacity(0.54), fontSize: 14),
                  ),
                )
              : ListView.separated(
                  padding:
                      const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 12),
                  itemCount: vm.bancos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final banco = vm.bancos[index];
                    final possuiCompras =
                        vm.comprasDoBanco(banco.id).isNotEmpty;
                    final bloqueado =
                        possuiCompras || vm.temFaturaInformada(banco.id);
                    return Dismissible(
                      key: Key(banco.id),
                      direction: bloqueado
                          ? DismissDirection.none
                          : DismissDirection.startToEnd,
                      background: Container(
                        decoration: BoxDecoration(
                          color: VermelhoExcluir.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.only(left: 18),
                        alignment: Alignment.centerLeft,
                        child: const Row(
                          children: [
                            Icon(Icons.delete_outline, color: Branco),
                            SizedBox(width: 6),
                            Text('Remover',
                                style: TextStyle(color: Branco)),
                          ],
                        ),
                      ),
                      confirmDismiss: (_) async {
                        _mostrarRemover(context, vm, banco);
                        return false;
                      },
                      child: GestureDetector(
                        onTap: () => onEditarBanco(banco.id),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(banco.cor),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: BancoListCard(
                                  banco: banco,
                                  fatura: formatarMoeda(
                                      vm.faturaDoBanco(banco.id)),
                                ),
                              ),
                              if (bloqueado)
                                Icon(Icons.lock,
                                    color: Branco.withOpacity(0.24),
                                    size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: (vm.iconesDisponiveis.isNotEmpty &&
                      vm.coresDisponiveis.isNotEmpty)
                  ? onNovoBanco
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: CorPrimaria,
                foregroundColor: Branco,
                disabledForegroundColor: Branco54,
                disabledBackgroundColor: SuperficieElevada,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Novo Banco',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _mostrarRemover(
      BuildContext context, FaturaViewModel vm, Banco banco) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Superficie,
        title: const Text('Remover banco?',
            style: TextStyle(color: Branco)),
        content: Text(
          'O banco ${banco.nome} será removido da lista.',
          style: TextStyle(color: Branco.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child:
                const Text('Cancelar', style: TextStyle(color: Branco54)),
          ),
          TextButton(
            onPressed: () {
              vm.removerBanco(banco.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Remover',
                style: TextStyle(color: VermelhoExcluir)),
          ),
        ],
      ),
    );
  }
}

class BancoListCard extends StatelessWidget {
  final Banco banco;
  final String fatura;

  const BancoListCard({
    super.key,
    required this.banco,
    required this.fatura,
  });

  @override
  Widget build(BuildContext context) {
    final corTexto = contrastePara(banco.cor);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BancoLogo(banco: banco, tamanho: 46, raio: 12),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                banco.nome,
                maxLines: 1,
                style: TextStyle(
                  color: corTexto,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Fatura: $fatura',
                style: TextStyle(color: corTexto.withOpacity(0.8), fontSize: 13),
              ),
            ],
          ),
        ),
        Text(
          fatura,
          style: TextStyle(
            color: corTexto,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
