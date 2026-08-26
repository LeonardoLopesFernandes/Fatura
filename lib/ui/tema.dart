import 'dart:math';
import 'package:flutter/material.dart';

const Color FundoInicio = Color(0xFF0A1128);
const Color FundoMeio = Color(0xFF0F1E3A);
const Color FundoFim = Color(0xFF1C305C);
const Color CorPrimaria = Color(0xFF2563EB);
const Color CorTextoEscura = Color(0xFF0B1226);
const Color Correto = Color(0xFF00C853);
const Color Superficie = Color(0xFF15244D);
const Color SuperficieElevada = Color(0xFF1D2F5E);
const Color NavBar = Color(0xFF0B1633);
const Color TituloAzul = Color(0xFFA0B2D8);
const Color VermelhoExcluir = Color(0xFFFF8A8A);
const Color VermelhoBotao = Color(0xFFC62828);
const Color Branco = Color(0xFFFFFFFF);
const Color Branco54 = Color(0x8CFFFFFF);
const Color Branco70 = Color(0xB3FFFFFF);
const Color Branco38 = Color(0x61FFFFFF);
const Color StatusBar = Color(0xFF0B1129);
const Color LacunaVermelha = Color(0xFFC62828);

double _canalLuminancia(int c) {
  final s = c / 255.0;
  return s <= 0.03928
      ? s / 12.92
      : pow((s + 0.055) / 1.055, 2.4).toDouble();
}

double luminance(int cor) {
  final r = (cor >> 16) & 0xFF;
  final g = (cor >> 8) & 0xFF;
  final b = cor & 0xFF;
  return 0.2126 * _canalLuminancia(r) +
      0.7152 * _canalLuminancia(g) +
      0.0722 * _canalLuminancia(b);
}

Color contrastePara(int cor) =>
    luminance(cor) > 0.45 ? CorTextoEscura : Branco;

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [FundoInicio, FundoMeio, FundoFim],
        ),
      ),
      child: child,
    );
  }
}
