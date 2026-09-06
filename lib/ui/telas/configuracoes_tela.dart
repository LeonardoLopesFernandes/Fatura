import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/fatura_view_model.dart';
import '../../ui/tema.dart';
import '../../util/backup.dart';
import '../../util/formatadores.dart';
import '../../util/notificacoes.dart';

class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FaturaViewModel>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: FundoInicio,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Branco54),
        ),
        title: const Text('Configurações',
            style: TextStyle(
                color: Branco, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            _Secao('Dados'),
            _Item(
              icone: Icons.upload,
              titulo: 'Exportar backup',
              subtitulo: 'Envie o arquivo de backup por qualquer app',
              onTap: () => exportarBackup(context, vm),
            ),
            _Item(
              icone: Icons.download,
              titulo: 'Importar backup',
              subtitulo: 'Restaure a partir de um arquivo JSON',
              onTap: () => importarBackup(context, vm),
            ),
            _Item(
              icone: Icons.delete_forever,
              titulo: 'Limpar dados',
              subtitulo: 'Remove todos os bancos, devedores e compras',
              cor: VermelhoExcluir,
              onTap: () => _confirmarLimpar(context, vm),
            ),
            _Secao('Lembretes'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary:
                  const Icon(Icons.notifications_active, color: Branco),
              title: const Text('Lembretes de fatura',
                  style: TextStyle(color: Branco, fontSize: 15)),
              subtitle: const Text(
                'Aviso diário e alerta de vencimento dos bancos',
                style: TextStyle(color: Branco54, fontSize: 12),
              ),
              value: vm.lembretesAtivos,
              activeColor: CorPrimaria,
              onChanged: (valor) {
                vm.definirLembretesAtivos(valor);
                agendarLembretes(valor);
              },
            ),
            _Secao('Contas fixas'),
            if (vm.fixas.isEmpty)
              const Text(
                'Nenhuma conta fixa cadastrada.\nAtive "Repetir todo mês" na nova compra.',
                style: TextStyle(color: Branco54, fontSize: 13),
              )
            else
              ...vm.fixas.map((fixa) {
                final banco = vm.bancoPorId(fixa.bancoId);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Superficie.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.repeat,
                      color: banco != null
                          ? Color(banco.cor)
                          : Branco,
                    ),
                    title: Text(fixa.descricao,
                        style:
                            const TextStyle(color: Branco, fontSize: 15)),
                    subtitle: Text(
                      '${banco?.nome ?? ''} · ${formatarMoeda(fixa.valorIndividual)}/mês',
                      style: const TextStyle(
                          color: Branco54, fontSize: 12),
                    ),
                    trailing: IconButton(
                      onPressed: () => _confirmarRemoverFixa(
                          context, vm, fixa.id, fixa.descricao),
                      icon: const Icon(Icons.delete_outline,
                          color: VermelhoExcluir),
                    ),
                  ),
                );
              }),
            _Secao('Sobre'),
            _Item(
              icone: Icons.info_outline,
              titulo: 'Sobre o Faturas',
              subtitulo: 'Versão e informações do app',
              onTap: () => _mostrarSobre(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarRemoverFixa(
    BuildContext context,
    FaturaViewModel vm,
    String id,
    String descricao,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Superficie,
        title: const Text('Remover conta fixa?',
            style: TextStyle(color: Branco)),
        content: Text(
          '"$descricao" não será mais lançada nos próximos meses. Lançamentos futuros pendentes serão apagados.',
          style: const TextStyle(color: Branco54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Branco54)),
          ),
          TextButton(
            onPressed: () {
              vm.removerFixa(id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Remover',
                style: TextStyle(color: VermelhoExcluir)),
          ),
        ],
      ),
    );
  }

  void _confirmarLimpar(BuildContext context, FaturaViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Superficie,
        title: const Text('Limpar todos os dados?',
            style: TextStyle(color: Branco)),
        content: const Text(
          'Esta ação removerá permanentemente bancos, devedores e compras.',
          style: TextStyle(color: Branco54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Branco54)),
          ),
          TextButton(
            onPressed: () {
              vm.limparTudo();
              Navigator.of(ctx).pop();
            },
            child: const Text('Limpar',
                style: TextStyle(color: VermelhoExcluir)),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarSobre(BuildContext context) async {
    String versao = '1.0.0';
    try {
      final conteudo = await rootBundle.loadString('pubspec.yaml');
      final match =
          RegExp(r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)')
              .firstMatch(conteudo);
      if (match != null) versao = match.group(1)!;
    } catch (_) {}
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Superficie,
        title: const Text('Faturas',
            style: TextStyle(color: Branco)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Controle de faturas compartilhadas entre devedores.',
              style: TextStyle(color: Branco54),
            ),
            const SizedBox(height: 8),
            Text('Versão: $versao',
                style: const TextStyle(color: Branco)),
            const SizedBox(height: 4),
            const Text('Desenvolvedor: Leonardo Lopes',
                style: TextStyle(color: Branco)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: CorPrimaria)),
          ),
        ],
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  final String titulo;
  const _Secao(this.titulo);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        titulo.toUpperCase(),
        style: const TextStyle(
          color: TituloAzul,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;
  final Color? cor;

  const _Item({
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
    this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Superficie.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icone, color: cor ?? Branco),
        title: Text(titulo,
            style: TextStyle(color: cor ?? Branco, fontSize: 15)),
        subtitle: Text(subtitulo,
            style: const TextStyle(color: Branco54, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right,
            color: Branco54),
        onTap: onTap,
      ),
    );
  }
}
