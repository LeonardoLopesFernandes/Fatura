import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/fatura_view_model.dart';
import '../../ui/tema.dart';
import '../../ui/temas.dart';
import '../../util/backup.dart';
import '../../util/formatadores.dart';
import '../../util/notificacoes.dart';

const String kVersaoApp = '1.0.36';

class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FaturaViewModel>(context);
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
        title: Text('Configurações',
            style: TextStyle(
                color: context.cores.texto, fontSize: 18, fontWeight: FontWeight.bold)),
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
              cor: context.cores.perigoClaro,
              onTap: () => _confirmarLimpar(context, vm),
            ),
            _Secao('Aparência'),
            ...rotulosTemas.entries.map((e) {
              final nome = e.key;
              final esquema = esquemas[nome]!;
              final ativo =
                  context.watch<TemaProvider>().nome == nome;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: context.cores.superficie.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: ativo
                        ? esquema.primaria
                        : context.cores.texto.withOpacity(0.08),
                    width: ativo ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: esquema.superficieElevada,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: esquema.texto.withOpacity(0.2)),
                    ),
                    child: Center(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: esquema.primaria,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  title: Text('Tema ${e.value}',
                      style: TextStyle(
                          color: context.cores.texto, fontSize: 15)),
                  subtitle: Text(
                    nome == 'amoled'
                        ? 'Preto puro, ideal para telas AMOLED'
                        : nome == 'claro'
                            ? 'Fundo claro para ambientes iluminados'
                            : 'Fundo escuro padrão',
                    style: TextStyle(
                        color: context.cores.textoSuave, fontSize: 12),
                  ),
                  trailing: ativo
                      ? Icon(Icons.check_circle,
                          color: esquema.primaria)
                      : null,
                  onTap: () => context
                      .read<TemaProvider>()
                      .definir(nome),
                ),
              );
            }),
            _Secao('Lembretes'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary:
                  Icon(Icons.notifications_active, color: context.cores.texto),
              title: Text('Lembretes de fatura',
                  style: TextStyle(color: context.cores.texto, fontSize: 15)),
              subtitle: Text(
                'Aviso diário e alerta de vencimento dos bancos',
                style: TextStyle(color: context.cores.textoSuave, fontSize: 12),
              ),
              value: vm.lembretesAtivos,
              activeColor: context.cores.sucesso,
              onChanged: (valor) {
                vm.definirLembretesAtivos(valor);
                agendarLembretes(valor);
              },
            ),
            _Secao('Contas fixas'),
            if (vm.fixas.isEmpty)
              Text(
                'Nenhuma conta fixa cadastrada.\nAtive "Repetir todo mês" na nova compra.',
                style: TextStyle(color: context.cores.textoSuave, fontSize: 13),
              )
            else
              ...vm.fixas.map((fixa) {
                final banco = vm.bancoPorId(fixa.bancoId);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: context.cores.superficie.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.repeat,
                      color: banco != null
                          ? Color(banco.cor)
                          : context.cores.texto,
                    ),
                    title: Text(fixa.descricao,
                        style:
                            TextStyle(color: context.cores.texto, fontSize: 15)),
                    subtitle: Text(
                      '${banco?.nome ?? ''} · ${formatarMoeda(fixa.valorIndividual)}/mês',
                      style: TextStyle(
                          color: context.cores.textoSuave, fontSize: 12),
                    ),
                    trailing: IconButton(
                      onPressed: () => _confirmarRemoverFixa(
                          context, vm, fixa.id, fixa.descricao),
                      icon: Icon(Icons.delete_outline,
                          color: context.cores.perigoClaro),
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
        backgroundColor: context.cores.superficie,
        title: Text('Remover conta fixa?',
            style: TextStyle(color: context.cores.texto)),
        content: Text(
          '"$descricao" não será mais lançada nos próximos meses. Lançamentos futuros pendentes serão apagados.',
          style: TextStyle(color: context.cores.textoSuave),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancelar', style: TextStyle(color: context.cores.textoSuave)),
          ),
          TextButton(
            onPressed: () {
              vm.removerFixa(id);
              Navigator.of(ctx).pop();
            },
            child: Text('Remover',
                style: TextStyle(color: context.cores.perigoClaro)),
          ),
        ],
      ),
    );
  }

  void _confirmarLimpar(BuildContext context, FaturaViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cores.superficie,
        title: Text('Limpar todos os dados?',
            style: TextStyle(color: context.cores.texto)),
        content: Text(
          'Esta ação removerá permanentemente bancos, devedores e compras.',
          style: TextStyle(color: context.cores.textoSuave),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancelar', style: TextStyle(color: context.cores.textoSuave)),
          ),
          TextButton(
            onPressed: () {
              vm.limparTudo();
              Navigator.of(ctx).pop();
            },
            child: Text('Limpar',
                style: TextStyle(color: context.cores.perigoClaro)),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarSobre(BuildContext context) async {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cores.superficie,
        title: Text('Faturas',
            style: TextStyle(color: context.cores.texto)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Controle de faturas compartilhadas entre devedores.',
              style: TextStyle(color: context.cores.textoSuave),
            ),
            const SizedBox(height: 8),
            Text('Versão: $kVersaoApp',
                style: TextStyle(color: context.cores.texto)),
            const SizedBox(height: 4),
            Text('Desenvolvedor: Leonardo Lopes',
                style: TextStyle(color: context.cores.texto)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK', style: TextStyle(color: context.cores.primaria)),
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
        style: TextStyle(
          color: context.cores.tituloSecao,
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
        color: context.cores.superficie.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icone, color: cor ?? context.cores.texto),
        title: Text(titulo,
            style: TextStyle(color: cor ?? context.cores.texto, fontSize: 15)),
        subtitle: Text(subtitulo,
            style: TextStyle(color: context.cores.textoSuave, fontSize: 12)),
        trailing: Icon(Icons.chevron_right,
            color: context.cores.textoSuave),
        onTap: onTap,
      ),
    );
  }
}
