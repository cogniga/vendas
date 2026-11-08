import 'package:flutter/material.dart';
import 'package:sales/core/theme/tokens.dart';

/// Cartão de indicador (KPI): rótulo, valor em destaque e subtexto opcional.
class KpiCard extends StatelessWidget {
  const KpiCard({
    required this.label,
    required this.value,
    this.sub,
    this.valorNegativo = false,
    super.key,
  });

  final String label;
  final String value;
  final String? sub;

  /// Pinta o valor com a cor de prejuízo (`bad`).
  final bool valorNegativo;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(Raios.cartao),
        border: Border.all(color: cores.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: textos.labelLarge?.copyWith(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: cores.muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: textos.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.44,
              color: valorNegativo ? cores.bad : null,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 6),
            Text(
              sub!,
              style: textos.bodySmall?.copyWith(
                fontSize: 12,
                color: cores.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Linha de KPIs: [Wrap] de cartões com largura-alvo ~170 px que ocupam o
/// espaço disponível (flex 1 1 170px do protótipo).
class KpiRow extends StatelessWidget {
  const KpiRow({required this.cartoes, this.larguraMinima = 170, super.key});

  final List<KpiCard> cartoes;
  final double larguraMinima;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final total = constraints.maxWidth;
        const espaco = Espacos.g12;
        // Quantos cabem respeitando a largura mínima.
        var colunas = ((total + espaco) / (larguraMinima + espaco)).floor();
        if (colunas < 1) colunas = 1;
        if (colunas > cartoes.length) colunas = cartoes.length;
        final largura = colunas <= 0
            ? total
            : (total - espaco * (colunas - 1)) / colunas;

        return Wrap(
          spacing: espaco,
          runSpacing: espaco,
          children: [
            for (final c in cartoes)
              SizedBox(width: largura, child: c),
          ],
        );
      },
    );
  }
}
