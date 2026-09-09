import 'package:flutter/material.dart';
import '../../models/banco.dart';
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
    const corTexto = Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 172,
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
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                BancoLogo(banco: banco, tamanho: 30, raio: 8),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    banco.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: corTexto,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              formatarMoeda(saldo),
              style: const TextStyle(
                color: corTexto,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              faturaInformada > 0
                  ? 'inf ${formatarMoeda(faturaInformada)} · resta ${formatarMoeda(restante)}'
                  : 'resta ${formatarMoeda(restante)}',
              style: TextStyle(
                color: corTexto.withOpacity(0.85),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
