import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/grupo.dart';
import '../../util/formatadores.dart';

Future<String?> gerarImagem({
  required String nome,
  required double fatura,
  required List<Grupo> grupos,
}) async {
  try {
    const int largura = 1080;
    final int altura =
        220 + grupos.fold<int>(0, (s, g) => s + 140 + g.compras.length * 64) + 80;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final fundo = Paint()..color = const Color(0xFF15244D);
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

    double y = 80;
    desenhar('FATURA INDIVIDUAL', 60, y, 30, const Color(0xFF9DB2E8),
        peso: FontWeight.bold);
    y += 100;
    desenhar(formatarMoeda(fatura), 60, y, 70, Colors.white,
        peso: FontWeight.bold);
    y += 120;
    for (final g in grupos) {
      desenhar(g.banco.nome.toUpperCase(), 60, y, 40, Colors.white,
          peso: FontWeight.bold);
      y += 64;
      for (final c in g.compras) {
        desenhar(c.descricao, 84, y, 34, const Color(0xFFE6ECF8));
        desenhar(formatarMoeda(c.valorTotal), (largura - 60).toDouble(), y, 34,
            Colors.white,
            right: true);
        y += 56;
      }
      y += 44;
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
