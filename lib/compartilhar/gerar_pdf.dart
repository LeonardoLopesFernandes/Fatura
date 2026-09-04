import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../models/grupo.dart';
import '../../util/formatadores.dart';

Future<String?> gerarPdf({
  required String nome,
  required double fatura,
  required List<Grupo> grupos,
}) async {
  try {
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
            final subtotal = g.compras.fold(0.0, (s, c) => s + c.valorIndividual);
            
            widgets.add(pw.Container(
              padding: pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: bancoCor,
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: bancoCor, width: 1),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: const PdfColor(0.95, 0.95, 0.95),
                      borderRadius: pw.BorderRadius.circular(20),
                    ),
                    child: pw.Text(g.banco.nome.toUpperCase(),
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.SizedBox(height: 16),
                  for (final c in g.compras)
                    pw.Padding(
                      padding: pw.EdgeInsets.only(bottom: 12),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Text(c.descricao,
                                style: pw.TextStyle(
                                    color: corTexto, fontSize: 12)),
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
