import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/grupo.dart';
import '../../data/icones_compra.dart';
import '../../util/formatadores.dart';

Future<String?> gerarImagem({
  required String nome,
  required double fatura,
  required List<Grupo> grupos,
}) async {
  try {
    const int largura = 1080;
    final int altura =
        300 + grupos.fold<int>(0, (s, g) => s + 180 + g.compras.length * 72) + 100;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final fundo = Paint()..color = const Color(0xFF0D1B2A);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, largura.toDouble(), altura.toDouble()),
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

    double y = 60;

    desenhar('FATURA INDIVIDUAL', 60, y, 28, const Color(0xFFA0B0C0),
        peso: FontWeight.bold);
    y += 60;
    desenhar(formatarMoeda(fatura), 60, y, 64, Colors.white,
        peso: FontWeight.bold);
    y += 100;

    for (final g in grupos) {
      final banco = g.banco;
      final corBanco = Color(banco.cor);
      final corBancoBg = corBanco.withOpacity(0.15);
      
      final cardHeight = 80.0 + g.compras.length * 72.0;
      desenharRetangulo(40, y, largura - 80, cardHeight, corBancoBg, 16);
      desenharBordaRetangulo(40, y, largura - 80, cardHeight, corBanco, 16, 2);

      double headerY = y + 20;
      
      desenharRetangulo(60, headerY, g.banco.nome.toUpperCase().length * 14.0 + 60, 36, Colors.white.withOpacity(0.1), 18);
      
      desenhar(g.banco.nome.toUpperCase(), 80, headerY + 8, 18, Colors.white,
          peso: FontWeight.bold);

      double itemY = headerY + 56;

      for (final c in g.compras) {
        desenharRetangulo(60, itemY, 40, 40, Colors.white.withOpacity(0.1), 8);
        
        desenhar(c.descricao, 112, itemY + 10, 20, const Color(0xFFE0E0E0));
        desenhar(formatarMoeda(c.valorIndividual), (largura - 60).toDouble(), itemY + 10, 20,
            Colors.white, right: true, peso: FontWeight.w600);
        
        itemY += 72;
      }

      y += cardHeight + 20;
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(largura, altura);
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
