import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EsquemaCores {
  final Color gradienteA;
  final Color gradienteB;
  final Color gradienteC;
  final Color superficie;
  final Color superficieElevada;
  final Color texto;
  final Color textoSuave;
  final Color textoMedio;
  final Color textoFraco;
  final Color primaria;
  final Color azulClaro;
  final Color textoSobreCor;
  final Color sucesso;
  final Color perigo;
  final Color perigoClaro;
  final Color tituloSecao;
  final Color navBar;
  final Color statusBar;
  final Color cinza;
  final bool claro;

  const EsquemaCores({
    required this.gradienteA,
    required this.gradienteB,
    required this.gradienteC,
    required this.superficie,
    required this.superficieElevada,
    required this.texto,
    required this.textoSuave,
    required this.textoMedio,
    required this.textoFraco,
    required this.primaria,
    required this.azulClaro,
    required this.textoSobreCor,
    required this.sucesso,
    required this.perigo,
    required this.perigoClaro,
    required this.tituloSecao,
    required this.navBar,
    required this.statusBar,
    required this.cinza,
    required this.claro,
  });
}

const EsquemaCores esquemaEscuro = EsquemaCores(
  gradienteA: Color(0xFF0A1128),
  gradienteB: Color(0xFF0F1E3A),
  gradienteC: Color(0xFF1C305C),
  superficie: Color(0xFF15244D),
  superficieElevada: Color(0xFF1D2F5E),
  texto: Color(0xFFFFFFFF),
  textoSuave: Color(0x8CFFFFFF),
  textoMedio: Color(0xB3FFFFFF),
  textoFraco: Color(0x61FFFFFF),
  primaria: Color(0xFF2563EB),
  azulClaro: Color(0xFF60A5FA),
  textoSobreCor: Color(0xFF0B1226),
  sucesso: Color(0xFF059669),
  perigo: Color(0xFFC62828),
  perigoClaro: Color(0xFFFF8A8A),
  tituloSecao: Color(0xFFA0B2D8),
  navBar: Color(0xFF0B1633),
  statusBar: Color(0xFF0B1129),
  cinza: Color(0xFF9AA4B2),
  claro: false,
);

const EsquemaCores esquemaClaro = EsquemaCores(
  gradienteA: Color(0xFFF1F5F9),
  gradienteB: Color(0xFFE2E8F0),
  gradienteC: Color(0xFFCBD5E1),
  superficie: Color(0xFFFFFFFF),
  superficieElevada: Color(0xFFF1F5F9),
  texto: Color(0xFF0B1226),
  textoSuave: Color(0x990B1226),
  textoMedio: Color(0xB30B1226),
  textoFraco: Color(0x610B1226),
  primaria: Color(0xFF2563EB),
  azulClaro: Color(0xFF1D6FF2),
  textoSobreCor: Color(0xFF0B1226),
  sucesso: Color(0xFF059669),
  perigo: Color(0xFFC62828),
  perigoClaro: Color(0xFFDC2626),
  tituloSecao: Color(0xFF47608F),
  navBar: Color(0xFFFFFFFF),
  statusBar: Color(0xFFFFFFFF),
  cinza: Color(0xFF64748B),
  claro: true,
);

const EsquemaCores esquemaAmoled = EsquemaCores(
  gradienteA: Color(0xFF000000),
  gradienteB: Color(0xFF000000),
  gradienteC: Color(0xFF000000),
  superficie: Color(0xFF0A0A0A),
  superficieElevada: Color(0xFF161616),
  texto: Color(0xFFFFFFFF),
  textoSuave: Color(0x8CFFFFFF),
  textoMedio: Color(0xB3FFFFFF),
  textoFraco: Color(0x61FFFFFF),
  primaria: Color(0xFF2563EA),
  azulClaro: Color(0xFFA8D3FF),
  textoSobreCor: Color(0xFF0B1226),
  sucesso: Color(0xFF059669),
  perigo: Color(0xFFFF5252),
  perigoClaro: Color(0xFFFF8A8A),
  tituloSecao: Color(0xFF8FB8F0),
  navBar: Color(0xFF000000),
  statusBar: Color(0xFF000000),
  cinza: Color(0xFF9AA4B2),
  claro: false,
);

const Map<String, EsquemaCores> esquemas = {
  'escuro': esquemaEscuro,
  'claro': esquemaClaro,
  'amoled': esquemaAmoled,
};

const Map<String, String> rotulosTemas = {
  'escuro': 'Escuro',
  'claro': 'Claro',
  'amoled': 'Amoled',
};

class TemaProvider extends ChangeNotifier {
  static const _chave = 'tema_app';
  String _nome = 'escuro';

  String get nome => _nome;
  EsquemaCores get cores => esquemas[_nome] ?? esquemaEscuro;
  bool get claro => cores.claro;

  Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    _nome = prefs.getString(_chave) ?? 'escuro';
    if (!esquemas.containsKey(_nome)) _nome = 'escuro';
    EsquemaAtual.valor = cores;
    aplicarSistema();
  }

  Future<void> definir(String nome) async {
    if (!esquemas.containsKey(nome) || nome == _nome) return;
    _nome = nome;
    EsquemaAtual.valor = cores;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chave, nome);
    aplicarSistema();
    notifyListeners();
  }

  void aplicarSistema() {
    final escuro = !cores.claro;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: cores.statusBar,
      statusBarIconBrightness:
          escuro ? Brightness.light : Brightness.dark,
      statusBarBrightness: escuro ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: cores.statusBar,
      systemNavigationBarIconBrightness:
          escuro ? Brightness.light : Brightness.dark,
    ));
  }
}

class EsquemaAtual {
  static EsquemaCores valor = esquemaEscuro;
}

extension TemaContext on BuildContext {
  EsquemaCores get cores =>
      Provider.of<TemaProvider>(this, listen: false).cores;
}
