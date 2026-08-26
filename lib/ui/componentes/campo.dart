import 'package:flutter/material.dart';
import '../../ui/tema.dart';

class Campo extends StatelessWidget {
  final String label;
  final Widget child;
  const Campo(this.label, this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              color: Branco70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}


InputDecoration campoCores(
  String label, {
  String? hint,
  Widget? prefixIcon,
}) {
  return InputDecoration(
    labelText: hint ?? label,
    labelStyle: const TextStyle(
      color: Branco70,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    prefixIcon: prefixIcon,
    filled: true,
    fillColor: SuperficieElevada,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}
