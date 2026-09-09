import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'temas.dart';

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

Color contrastePara(int cor) => luminance(cor) > 0.45
    ? const Color(0xFF0B1226)
    : const Color(0xFFFFFFFF);

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final cores = context.watch<TemaProvider>().cores;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [cores.gradienteA, cores.gradienteB, cores.gradienteC],
        ),
      ),
      child: child,
    );
  }
}
