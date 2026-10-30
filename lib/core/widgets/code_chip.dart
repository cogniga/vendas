import 'package:flutter/material.dart';
import 'package:sales/core/theme/tokens.dart';

/// Chip monoespaçado para códigos (SKU, nº do pedido), estilo 11,5/600.
class CodeChip extends StatelessWidget {
  const CodeChip(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cores.surface2,
        borderRadius: BorderRadius.circular(Raios.pill),
        border: Border.all(color: cores.line),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: cores.muted,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
