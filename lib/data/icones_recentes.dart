import 'package:shared_preferences/shared_preferences.dart';

class IconesRecentes {
  static const _chave = 'icones_compra_recentes';
  static const _maximo = 8;

  static Future<List<String>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_chave) ?? [];
  }

  static Future<void> registrar(String? chave) async {
    if (chave == null || chave.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final lista =
        prefs.getStringList(_chave) ?? <String>[];
    lista.remove(chave);
    lista.insert(0, chave);
    await prefs.setStringList(
        _chave, lista.take(_maximo).toList());
  }
}
