import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../ui/temas.dart';

Future<String?> escolherImagemCortada(
  BuildContext context, {
  required String pasta,
  required String prefixo,
}) async {
  try {
    final picker = ImagePicker();
    final imagem = await picker.pickImage(source: ImageSource.gallery);
    if (imagem == null) return null;
    if (!context.mounted) return null;
    final bytes = await File(imagem.path).readAsBytes();
    final cortados = await Navigator.of(context).push<Uint8List?>(
      MaterialPageRoute(
        builder: (_) => _TelaCorte(imagem: bytes),
      ),
    );
    if (cortados == null) return null;
    final dir =
        Directory('${(await getApplicationDocumentsDirectory()).path}/$pasta');
    await dir.create(recursive: true);
    final destino =
        '${dir.path}/${prefixo}_${DateTime.now().microsecondsSinceEpoch}.png';
    await File(destino).writeAsBytes(cortados, flush: true);
    return destino;
  } catch (_) {
    return null;
  }
}

class _TelaCorte extends StatefulWidget {
  final Uint8List imagem;
  const _TelaCorte({required this.imagem});

  @override
  State<_TelaCorte> createState() => _TelaCorteState();
}

class _TelaCorteState extends State<_TelaCorte> {
  late final CropController _controller;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _controller = CropController(
      aspectRatio: 1,
      defaultCrop: const Rect.fromLTRB(0.05, 0.05, 0.95, 0.95),
    );
  }

  Future<void> _usar() async {
    if (_salvando) return;
    setState(() => _salvando = true);
    try {
      final ui.Image bitmap = await _controller.croppedBitmap();
      final dados =
          await bitmap.toByteData(format: ui.ImageByteFormat.png);
      if (!mounted) return;
      Navigator.of(context).pop(dados?.buffer.asUint8List());
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = EsquemaAtual.valor;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: cores.superficie,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close, color: cores.texto),
        ),
        title: Text('Ajustar imagem',
            style: TextStyle(color: cores.texto, fontSize: 17)),
        actions: [
          IconButton(
            onPressed: () => _controller.rotateLeft(),
            icon: Icon(Icons.rotate_left, color: cores.texto),
          ),
          IconButton(
            onPressed: () => _controller.rotateRight(),
            icon: Icon(Icons.rotate_right, color: cores.texto),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CropImage(
              controller: _controller,
              image: Image.memory(widget.imagem),
              gridColor: cores.primaria,
              scrimColor: Colors.black.withOpacity(0.6),
              alwaysShowThirdLines: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _salvando ? null : _usar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cores.primaria,
                  foregroundColor: cores.texto,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Usar imagem',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
