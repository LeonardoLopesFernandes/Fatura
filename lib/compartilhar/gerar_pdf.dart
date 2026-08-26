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
    final fundo = PdfColor.fromInt(0xFF15244D);
    final corTitulo = PdfColor.fromInt(0xFF9DB2E8);
    final corTexto = PdfColor.fromInt(0xFFE6ECF8);

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
          widgets.add(pw.Text(nome,
              style: pw.TextStyle(
                  color: corTitulo,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold)));
          widgets.add(pw.SizedBox(height: 16));
          widgets.add(pw.Text('Fatura individual: ${formatarMoeda(fatura)}',
              style: pw.TextStyle(color: corTexto, fontSize: 14)));
          widgets.add(pw.SizedBox(height: 18));
          for (final g in grupos) {
            widgets.add(pw.Text(g.banco.nome.toUpperCase(),
                style: pw.TextStyle(
                    color: corTitulo,
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold)));
            widgets.add(pw.SizedBox(height: 8));
            for (final c in g.compras) {
              widgets.add(pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(c.descricao,
                        style: pw.TextStyle(color: corTexto, fontSize: 12)),
                  ),
                  pw.Text(formatarMoeda(c.valorTotal),
                      style: pw.TextStyle(color: corTexto, fontSize: 12)),
                ],
              ));
              widgets.add(pw.SizedBox(height: 6));
            }
            widgets.add(pw.SizedBox(height: 12));
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
