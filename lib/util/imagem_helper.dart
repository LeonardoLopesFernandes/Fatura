import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
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
    final cores = EsquemaAtual.valor;
    final cortada = await ImageCropper().cropImage(
      sourcePath: imagem.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Ajustar imagem',
          toolbarColor: cores.superficie,
          toolbarWidgetColor: cores.texto,
          activeControlsWidgetColor: cores.primaria,
          backgroundColor: cores.superficie,
          statusBarColor: cores.statusBar,
          cropFrameColor: cores.primaria,
          cropGridColor: cores.texto.withOpacity(0.5),
          dimmedLayerColor: cores.texto.withOpacity(0.6),
          showCropGrid: true,
          lockAspectRatio: true,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Ajustar imagem',
          doneButtonTitle: 'Usar',
          cancelButtonTitle: 'Cancelar',
          aspectRatioLockEnabled: true,
        ),
      ],
    );
    if (cortada == null) return null;
    final dir =
        Directory('${(await getApplicationDocumentsDirectory()).path}/$pasta');
    await dir.create(recursive: true);
    final ext = cortada.path.split('.').last;
    final destino =
        '${dir.path}/${prefixo}_${DateTime.now().microsecondsSinceEpoch}.$ext';
    await File(cortada.path).copy(destino);
    return destino;
  } catch (_) {
    return null;
  }
}
