import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

Future<void> compartilharArquivo(
  BuildContext context,
  String? caminho,
  String mime,
  String nome,
) async {
  if (caminho == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Não foi possível gerar o arquivo para compartilhar.'),
      ),
    );
    return;
  }
  final arquivo = XFile(caminho, mimeType: mime);
  await Share.shareXFiles(
    [arquivo],
    subject: 'Compras de $nome',
    sharePositionOrigin: null,
  );
}
