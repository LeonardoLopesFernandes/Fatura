import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../models/compra.dart';
import '../../models/grupo.dart';
import '../../models/mes.dart';
import '../../data/icones_compra.dart';
import '../../util/formatadores.dart';

PdfColor _misturar(PdfColor base, PdfColor sobre, double t) => PdfColor(
      base.red + (sobre.red - base.red) * t,
      base.green + (sobre.green - base.green) * t,
      base.blue + (sobre.blue - base.blue) * t,
    );

String _rotuloParcelaPdf(Compra c, Mes? mes) {
  if (c.quantidadeParcelas <= 1) return 'Mensal';
  final n = mes != null ? c.parcelaNoMes(mes) : 0;
  if (n > 0) return 'Parcela $n de ${c.quantidadeParcelas}';
  return '${c.quantidadeParcelas}x';
}

Future<Uint8List?> _iconePng(IconData icone) async {
  try {
    const size = 64.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icone.codePoint),
        style: TextStyle(
          fontSize: 48,
          color: const Color(0xFF0D1B2A),
          fontFamily: icone.fontFamily,
          package: icone.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset((size - tp.width) / 2, (size - tp.height) / 2),
    );
    final img = await recorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  } catch (_) {
    return null;
  }
}

Future<String?> gerarPdf({
  required String nome,
  required double fatura,
  required List<Grupo> grupos,
  Mes? mes,
}) async {
  try {
    final icones = <String, Uint8List>{};
    final fotos = <String, Uint8List>{};
    for (final g in grupos) {
      for (final c in g.compras) {
        if (c.iconeArquivo != null) {
          try {
            fotos[c.id] = await File(c.iconeArquivo!).readAsBytes();
            continue;
          } catch (_) {}
        }
        final icone = c.iconeChave != null
            ? IconesCompra.iconePorChave(c.iconeChave)
            : IconesCompra.iconePorDescricao(c.descricao);
        final png = await _iconePng(icone);
        if (png != null) icones[c.id] = png;
      }
    }

    pw.Widget iconeCompra(Compra c, PdfColor bancoCor) {
      if (fotos.containsKey(c.id)) {
        return pw.Container(
          width: 30,
          height: 30,
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.ClipRRect(
            horizontalRadius: 8,
            verticalRadius: 8,
            child: pw.Image(
              pw.MemoryImage(fotos[c.id]!),
              width: 30,
              height: 30,
              fit: pw.BoxFit.cover,
            ),
          ),
        );
      }
      if (icones.containsKey(c.id)) {
        return pw.Container(
          width: 30,
          height: 30,
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          padding: pw.EdgeInsets.all(4),
          child: pw.Image(
            pw.MemoryImage(icones[c.id]!),
            width: 22,
            height: 22,
          ),
        );
      }
      return pw.Container(
        width: 30,
        height: 30,
        decoration: const pw.BoxDecoration(
          color: PdfColors.white,
          shape: pw.BoxShape.circle,
        ),
        child: pw.Center(
          child: pw.Text(
            c.descricao.trim().isNotEmpty
                ? c.descricao.trim().substring(0, 1).toUpperCase()
                : '?',
            style: pw.TextStyle(
              color: bancoCor,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      );
    }
    final doc = pw.Document();
    final fundo = PdfColor.fromInt(0xFF0D1B2A);
    final corTitulo = PdfColor.fromInt(0xFFA0B0C0);
    final corTexto = PdfColor.fromInt(0xFFE0E0E0);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData(
          defaultTextStyle: pw.TextStyle(color: corTexto, fontSize: 12),
        ),
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(40),
          buildBackground: (_) => pw.Container(
            width: double.infinity,
            height: double.infinity,
            color: fundo,
          ),
        ),
        build: (_) {
          final widgets = <pw.Widget>[];
          
          widgets.add(pw.Text(nome.toUpperCase(),
              style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold)));
          widgets.add(pw.SizedBox(height: 4));
          widgets.add(pw.Text('FATURA INDIVIDUAL',
              style: pw.TextStyle(
                  color: corTitulo,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold)));
          widgets.add(pw.SizedBox(height: 8));
          widgets.add(pw.Text(formatarMoeda(fatura),
              style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold)));
          widgets.add(pw.SizedBox(height: 24));

          for (final g in grupos) {
            final bancoCor = PdfColor.fromInt(g.banco.cor);
            final subtotal =
                g.compras.fold(0.0, (s, c) => s + c.valorIndividual);
            final cardBg = _misturar(fundo, bancoCor, 0.15);
            final brilho = _misturar(fundo, bancoCor, 0.35);

            widgets.add(pw.Padding(
              padding: pw.EdgeInsets.symmetric(horizontal: 24),
              child: pw.Container(
              decoration: pw.BoxDecoration(
                color: brilho,
                borderRadius: pw.BorderRadius.circular(14),
              ),
              padding: pw.EdgeInsets.all(2),
              child: pw.Container(
              padding: pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: cardBg,
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: bancoCor, width: 1.5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(
                        width: 32,
                        height: 32,
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.white,
                          shape: pw.BoxShape.circle,
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            g.banco.nome.trim().isNotEmpty
                                ? g.banco.nome.trim().substring(0, 1).toUpperCase()
                                : '?',
                            style: pw.TextStyle(
                              color: bancoCor,
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Text(g.banco.nome.toUpperCase(),
                            style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Text(formatarMoeda(subtotal),
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  for (final c in g.compras)
                    pw.Padding(
                      padding: pw.EdgeInsets.only(bottom: 12),
                      child: pw.Row(
                        crossAxisAlignment:
                            pw.CrossAxisAlignment.center,
                        children: [
                          iconeCompra(c, bancoCor),
                          pw.SizedBox(width: 10),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment:
                                  pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(c.descricao,
                                    style: pw.TextStyle(
                                        color: corTexto,
                                        fontSize: 12)),
                                pw.Text(_rotuloParcelaPdf(c, mes),
                                    style: pw.TextStyle(
                                        color: corTitulo,
                                        fontSize: 9)),
                              ],
                            ),
                          ),
                          pw.Text(formatarMoeda(c.valorIndividual),
                              style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),
                ],
              ),
              ),
              ),
            ));
            widgets.add(pw.SizedBox(height: 16));
          }

          return widgets;
        },
      ),
    );

    final dir = Directory(
        '${(await getTemporaryDirectory()).path}/compartilhamento');
    await dir.create(recursive: true);
    final file = File('${dir.path}/compras_${limparNome(nome)}.pdf');
    await file.writeAsBytes(await doc.save());
    return file.path;
  } catch (_) {
    return null;
  }
}
