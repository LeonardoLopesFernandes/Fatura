import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui/temas.dart';

class Campo extends StatefulWidget {
  final String label;
  final String? hint;
  final FocusNode? focusNode;
  final Widget child;

  const Campo(
    this.label,
    this.child, {
    this.hint,
    this.focusNode,
    super.key,
  });

  @override
  State<Campo> createState() => _CampoState();
}

class _CampoState extends State<Campo> {
  late final FocusNode _focus;
  bool _focado = false;

  @override
  void initState() {
    super.initState();
    _focus = widget.focusNode ?? FocusNode();
    _focus.addListener(_aoMudarFoco);
  }

  void _aoMudarFoco() => setState(() => _focado = _focus.hasFocus);

  @override
  void dispose() {
    _focus.removeListener(_aoMudarFoco);
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.watch<TemaProvider>().cores;
    final titulo =
        (_focado && widget.hint != null) ? widget.hint! : widget.label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            color: cores.textoMedio,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        widget.child,
      ],
    );
  }
}

InputDecoration campoCores(
  String label, {
  String? hint,
  Widget? prefixIcon,
  bool flutuante = true,
}) {
  final textoDica = hint ?? label;
  final cores = EsquemaAtual.valor;
  return InputDecoration(
    labelText: flutuante ? textoDica : null,
    hintText: flutuante ? null : (textoDica.isEmpty ? null : textoDica),
    labelStyle: TextStyle(
      color: cores.textoMedio,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    hintStyle: TextStyle(
      color: cores.cinza,
      fontSize: 13,
    ),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    prefixIcon: prefixIcon,
    filled: true,
    fillColor: cores.superficieElevada,
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
        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  );
}
