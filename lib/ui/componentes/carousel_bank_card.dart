import 'package:flutter/material.dart';
import '../../models/banco.dart';
import '../../ui/tema.dart';
import '../../ui/componentes/banco_logo.dart';
import '../../util/formatadores.dart';

class CarouselBankCard extends StatelessWidget {
  final Banco banco;
  final double saldo;
  final double restante;
  final double faturaInformada;
  final VoidCallback? onTap;

  const CarouselBankCard({
    super.key,
    required this.banco,
    required this.saldo,
    this.restante = 0.0,
    this.faturaInformada = 0.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final corTexto = contrastePara(banco.cor);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 128,
        decoration: BoxDecoration(
          color: Color(banco.cor),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BancoLogo(banco: banco, tamanho: 34, raio: 9),
            const SizedBox(height: 6),
            Text(
              banco.nome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: corTexto,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              formatarMoeda(saldo),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: corTexto,
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              faturaInformada > 0
                  ? 'inf ${formatarMoeda(faturaInformada)} · resta ${formatarMoeda(restante)}'
                  : 'resta ${formatarMoeda(restante)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                color: corTexto.withOpacity(faturaInformada > 0 ? 0.85 : 0.7),
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
