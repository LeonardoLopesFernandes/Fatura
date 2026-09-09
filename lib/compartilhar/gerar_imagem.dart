import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/compra.dart';
import '../../models/grupo.dart';
import '../../models/mes.dart';
import '../../data/icones_compra.dart';
import '../../util/formatadores.dart';

String rotuloParcelaCompra(Compra c, Mes? mes) {
  if (c.quantidadeParcelas <= 1) return 'Mensal';
  final n = mes != null ? c.parcelaNoMes(mes) : 0;
  if (n > 0) return 'Parcela $n de ${c.quantidadeParcelas}';
  return '${c.quantidadeParcelas}x';
}

Future<String?> gerarImagem({
  required String nome,
  required double fatura,
  required List<Grupo> grupos,
  Mes? mes,
}) async {
  try {
    const int largura = 1080;
    const double escala = 3.0;
    final int alturaLogica =
        400 + grupos.fold<int>(0, (s, g) => s + 132 + g.compras.length * 100) + 120;
    // altura por grupo = cardHeight (112 + n*100) + espaçamento 20

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(escala);
    final fundo = Paint()..color = const Color(0xFF0D1B2A);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, largura.toDouble(), alturaLogica.toDouble()),
      fundo,
    );

    void desenhar(
      String texto,
      double x,
      double y,
      double size,
      Color cor, {
      bool right = false,
      FontWeight peso = FontWeight.normal,
    }) {
      final tp = TextPainter(
        text: TextSpan(
          text: texto,
          style: TextStyle(fontSize: size, color: cor, fontWeight: peso),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      final dx = right ? x - tp.width : x;
      tp.paint(canvas, Offset(dx, y));
    }

    void desenharRetangulo(
      double x,
      double y,
      double w,
      double h,
      Color cor,
      double raio,
    ) {
      final paint = Paint()..color = cor;
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        Radius.circular(raio),
      );
      canvas.drawRRect(rrect, paint);
    }

    void desenharBordaRetangulo(
      double x,
      double y,
      double w,
      double h,
      Color cor,
      double raio,
      double espessura,
    ) {
      final paint = Paint()
        ..color = cor
        ..style = PaintingStyle.stroke
        ..strokeWidth = espessura;
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        Radius.circular(raio),
      );
      canvas.drawRRect(rrect, paint);
    }

    void desenharAvatarLetra(
      String letra,
      double cx,
      double cy,
      double diametro,
      Color corLetra,
    ) {
      canvas.drawCircle(
        Offset(cx, cy),
        diametro / 2,
        Paint()..color = Colors.white,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: letra,
          style: TextStyle(
            fontSize: diametro * 0.52,
            color: corLetra,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      tp.layout(maxWidth: diametro);
      tp.paint(
        canvas,
        Offset(cx - tp.width / 2, cy - tp.height / 2),
      );
    }

    void desenharIconeCompra(IconData icone, double boxX, double boxY) {
      const box = 44.0;
      final tp = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icone.codePoint),
          style: TextStyle(
            fontSize: 26,
            color: const Color(0xFFE0E0E0),
            fontFamily: icone.fontFamily,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(boxX + (box - tp.width) / 2, boxY + (box - tp.height) / 2),
      );
    }

    double y = 60;

    desenhar(nome.toUpperCase(), 60, y, 44, Colors.white,
        peso: FontWeight.w900);
    y += 72;
    desenhar('FATURA INDIVIDUAL', 60, y, 28, const Color(0xFFA0B0C0),
        peso: FontWeight.bold);
    y += 60;
    desenhar(formatarMoeda(fatura), 60, y, 64, Colors.white,
        peso: FontWeight.bold);
    y += 110;

    for (final g in grupos) {
      final banco = g.banco;
      final corBanco = Color(banco.cor);
      final corBancoBg = corBanco.withOpacity(0.15);
      final subtotal =
          g.compras.fold(0.0, (s, c) => s + c.valorIndividual);

      final cardHeight = 112.0 + g.compras.length * 100.0;
      desenharRetangulo(40, y, largura - 80, cardHeight, corBancoBg, 20);
      desenharBordaRetangulo(40, y, largura - 80, cardHeight, corBanco, 20, 2);

      final headerY = y + 20;
      const avatarD = 56.0;
      final letra = banco.nome.trim().isNotEmpty
          ? banco.nome.trim().substring(0, 1).toUpperCase()
          : '?';
      desenharAvatarLetra(
          letra, 60 + avatarD / 2, headerY + avatarD / 2, avatarD, corBanco);

      desenhar(banco.nome.toUpperCase(), 132, headerY + 8, 22, Colors.white,
          peso: FontWeight.bold);
      desenhar(formatarMoeda(subtotal), (largura - 60).toDouble(),
          headerY + 6, 24, Colors.white,
          right: true, peso: FontWeight.bold);

      double itemY = headerY + 76;

      for (final c in g.compras) {
        desenharRetangulo(60, itemY + 8, 44, 44, Colors.white.withOpacity(0.12), 10);
        final icone = c.iconeChave != null
            ? IconesCompra.iconePorChave(c.iconeChave)
            : IconesCompra.iconePorDescricao(c.descricao);
        desenharIconeCompra(icone, 60, itemY + 8);

        desenhar(c.descricao, 118, itemY + 8, 20, const Color(0xFFE0E0E0));
        desenhar(rotuloParcelaCompra(c, mes), 118, itemY + 36, 15,
            const Color(0xFFA0B0C0));
        desenhar(formatarMoeda(c.valorIndividual),
            (largura - 60).toDouble(), itemY + 28, 20, Colors.white,
            right: true, peso: FontWeight.w600);

        itemY += 100;
      }

      y += cardHeight + 20;
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (largura * escala).round(),
      (alturaLogica * escala).round(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory(
        '${(await getTemporaryDirectory()).path}/compartilhamento');
    await dir.create(recursive: true);
    final file = File('${dir.path}/compras_${limparNome(nome)}.png');
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    return file.path;
  } catch (_) {
    return null;
  }
}
