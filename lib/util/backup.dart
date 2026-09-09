import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../ui/tema.dart';
import '../ui/temas.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../data/fatura_view_model.dart';

Future<void> exportarBackup(
    BuildContext context, FaturaViewModel vm) async {
  try {
    final dir = Directory(
        '${(await getTemporaryDirectory()).path}/compartilhamento');
    await dir.create(recursive: true);
    final file = File('${dir.path}/faturas_backup.json');
    await file.writeAsString(vm.exportarJson());
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: 'Backup das faturas',
    );
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível exportar.')),
      );
    }
  }
}

Future<void> importarBackup(
    BuildContext context, FaturaViewModel vm) async {
  final confirmar = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: context.cores.superficie,
      title: Text('Importar backup?',
          style: TextStyle(color: context.cores.texto)),
      content: Text(
        'Isso substituirá todos os dados atuais pelos do arquivo de backup.',
        style: TextStyle(color: context.cores.textoSuave),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text('Cancelar', style: TextStyle(color: context.cores.textoSuave)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text('Importar', style: TextStyle(color: context.cores.azulClaro)),
        ),
      ],
    ),
  );
  if (confirmar != true) return;
  try {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (resultado == null || resultado.files.isEmpty) return;
    final arquivo = resultado.files.first;
    if (arquivo.path == null) return;
    final conteudo = await File(arquivo.path!).readAsString();
    final ok = vm.importarJson(conteudo);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? 'Backup importado com sucesso.'
              : 'Arquivo de backup inválido.'),
        ),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível ler o arquivo.')),
      );
    }
  }
}
