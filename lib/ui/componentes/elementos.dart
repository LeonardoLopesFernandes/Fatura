import 'package:flutter/material.dart';
import '../../models/mes.dart';
import '../../util/formatadores.dart';
import '../../ui/tema.dart';

class TituloSecao extends StatelessWidget {
  final String titulo;
  const TituloSecao(this.titulo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo.toUpperCase(),
      style: const TextStyle(
        color: TituloAzul,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}

class MensagemVazia extends StatelessWidget {
  final String texto;
  const MensagemVazia(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Branco.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Branco.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.all(24),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: TextStyle(color: Branco.withOpacity(0.54), fontSize: 14),
      ),
    );
  }
}

class BotaoMes extends StatelessWidget {
  final IconData icone;
  final VoidCallback aoTocar;
  const BotaoMes(this.icone, this.aoTocar, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: aoTocar,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: SuperficieElevada,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icone, color: Branco),
      ),
    );
  }
}

class CabecalhoMes extends StatelessWidget {
  final Mes mes;
  final VoidCallback aoAnterior;
  final VoidCallback aoProximo;
  const CabecalhoMes(this.mes, this.aoAnterior, this.aoProximo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Superficie.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Branco.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BotaoMes(Icons.chevron_left, aoAnterior),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'MÊS',
                  style: TextStyle(
                    color: TituloAzul,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rotuloMesLongo(mes).toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Branco,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          BotaoMes(Icons.chevron_right, aoProximo),
        ],
      ),
    );
  }
}
