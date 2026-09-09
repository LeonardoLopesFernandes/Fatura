import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/comprador.dart';
import '../../data/avatares.dart';
import '../../ui/temas.dart';

class AvatarDevedor extends StatelessWidget {
  final Comprador comprador;
  final double tamanho;
  final double raio;
  final Color? corFundo;

  const AvatarDevedor({
    super.key,
    required this.comprador,
    this.tamanho = 48,
    this.raio = 14,
    this.corFundo,
  });

  @override
  Widget build(BuildContext context) {
    final fundo = corFundo ?? context.cores.primaria;
    Widget conteudo;
    if (comprador.avatarArquivo != null) {
      conteudo = Image.file(
        File(comprador.avatarArquivo!),
        width: tamanho,
        height: tamanho,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(
          Avatares.iconePorChave(comprador.avatarChave),
          color: context.cores.texto,
          size: tamanho * 0.55,
        ),
      );
    } else if (comprador.avatarChave != null) {
      conteudo = Icon(
        Avatares.iconePorChave(comprador.avatarChave),
        color: context.cores.texto,
        size: tamanho * 0.55,
      );
    } else {
      final letra = comprador.nome.trim().isNotEmpty
          ? comprador.nome.trim().substring(0, 1).toUpperCase()
          : '?';
      conteudo = Text(
        letra,
        style: TextStyle(
          color: context.cores.texto,
          fontSize: tamanho * 0.5,
          fontWeight: FontWeight.w800,
        ),
      );
    }

    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(raio),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(raio),
        child: Center(child: conteudo),
      ),
    );
  }
}
