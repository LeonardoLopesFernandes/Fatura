import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/banco.dart';
import '../../data/catalogo_icones.dart';
import '../../data/recursos_banco.dart';
import '../../ui/tema.dart';

class BancoLogo extends StatelessWidget {
  final Banco banco;
  final double tamanho;
  final double raio;

  const BancoLogo({
    super.key,
    required this.banco,
    this.tamanho = 44,
    this.raio = 12,
  });

  @override
  Widget build(BuildContext context) {
    final corIcone = Color(banco.cor);
    final inner = tamanho * 0.62;
    final padding = tamanho * 0.14;

    Widget conteudo;
    if (banco.iconeArquivo != null) {
      conteudo = Image.file(
        File(banco.iconeArquivo!),
        width: inner,
        height: inner,
        fit: BoxFit.contain,
      );
    } else if (banco.iconeRes != null) {
      final asset = RecursosBanco.DRAWABLES[banco.iconeRes];
      if (asset != null) {
        if (asset.endsWith('.svg')) {
          conteudo = SvgPicture.asset(
            asset,
            width: inner,
            height: inner,
            fit: BoxFit.contain,
            colorFilter: banco.corDoIcone != null
                ? ColorFilter.mode(
                    Color(banco.corDoIcone!), BlendMode.srcIn)
                : null,
          );
        } else {
          conteudo = Image.asset(
            asset,
            width: inner,
            height: inner,
            fit: BoxFit.contain,
            color: banco.corDoIcone != null ? Color(banco.corDoIcone!) : null,
            colorBlendMode: BlendMode.srcIn,
          );
        }
      } else {
        conteudo = _iconePadrao(corIcone);
      }
    } else {
      conteudo = _iconePadrao(corIcone);
    }

    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        color: Branco,
        borderRadius: BorderRadius.circular(raio),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(raio * 0.5),
        child: FittedBox(fit: BoxFit.contain, child: conteudo),
      ),
    );
  }

  Widget _iconePadrao(Color corIcone) {
    final icone = IconesCatalogo.iconePorChave(banco.iconeChave);
    return Icon(
      icone ?? Icons.credit_card,
      color: corIcone,
      size: tamanho * 0.5,
    );
  }
}
