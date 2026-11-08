import 'package:flutter/material.dart';

/// Grade auto-fit do protótipo (`.grid.g2`): colunas de no mínimo
/// [larguraMinima] que dividem o espaço igualmente. Sem `IntrinsicHeight`:
/// cada painel tem a própria altura.
class GradePaineis extends StatelessWidget {
  const GradePaineis({
    required this.filhos,
    this.larguraMinima = 340,
    this.espaco = 16,
    super.key,
  });

  final List<Widget> filhos;
  final double larguraMinima;
  final double espaco;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final total = constraints.maxWidth;
        var colunas = ((total + espaco) / (larguraMinima + espaco)).floor();
        if (colunas < 1) colunas = 1;
        if (colunas > filhos.length) colunas = filhos.length;
        if (colunas < 1) return const SizedBox.shrink();
        final largura = (total - espaco * (colunas - 1)) / colunas;
        return Wrap(
          spacing: espaco,
          runSpacing: espaco,
          children: [
            for (final f in filhos) SizedBox(width: largura, child: f),
          ],
        );
      },
    );
  }
}
