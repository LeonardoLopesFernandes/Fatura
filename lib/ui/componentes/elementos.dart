import 'package:flutter/material.dart';
import '../../models/mes.dart';
import '../../util/formatadores.dart';
import '../../ui/tema.dart';
import '../../ui/temas.dart';

class TituloSecao extends StatelessWidget {
  final String titulo;
  const TituloSecao(this.titulo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo.toUpperCase(),
      style: TextStyle(
        color: context.cores.tituloSecao,
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
        color: context.cores.texto.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cores.texto.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.all(16),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: TextStyle(color: context.cores.texto.withOpacity(0.54), fontSize: 14),
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
          color: context.cores.superficieElevada,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icone, color: context.cores.texto),
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
    final eAtual = mes == hojeMes();
    const corDestaque = Color(0xFF60A5FA);
    return Container(
      decoration: BoxDecoration(
        color: context.cores.superficie.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cores.texto.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BotaoMes(Icons.chevron_left, aoAnterior),
          Expanded(
            child: Column(
              children: [
                Text(
                  eAtual ? 'MÊS ATUAL' : 'MÊS',
                  style: TextStyle(
                    color: eAtual ? corDestaque : context.cores.tituloSecao,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${DateTime.now().day.toString().padLeft(2, '0')} ${rotuloMesLongo(mes).toUpperCase()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: eAtual ? corDestaque : context.cores.texto,
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
