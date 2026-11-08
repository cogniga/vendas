import 'package:flutter/material.dart';
import 'package:sales/core/theme/tokens.dart';

/// Cartão de indicador (KPI): rótulo, valor em destaque e subtexto opcional.
class KpiCard extends StatelessWidget {
  const KpiCard({
    required this.label,
    required this.value,
    this.sub,
    this.valorNegativo = false,
    this.destaque = false,
    super.key,
  });

  final String label;
  final String value;
  final String? sub;

  /// Pinta o valor com a cor de prejuízo (`bad`).
  final bool valorNegativo;

  /// Cartão em destaque (verde: fundo `goodSoft`, borda e valor `good`).
  /// Com [valorNegativo], o destaque fica vermelho (`badSoft`/`bad`) para não
  /// mostrar prejuízo em verde.
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final corDestaque = valorNegativo ? cores.bad : cores.good;
    final corValor = destaque
        ? corDestaque
        : (valorNegativo ? cores.bad : null);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: destaque
            ? (valorNegativo ? cores.badSoft : cores.goodSoft)
            : cores.surface,
        borderRadius: BorderRadius.circular(Raios.cartao),
        border: Border.all(
          color: destaque ? corDestaque.withValues(alpha: 0.35) : cores.line,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: textos.labelLarge?.copyWith(
              fontSize: 12.5,
              fontWeight: destaque ? FontWeight.w600 : FontWeight.w500,
              color: destaque ? corDestaque : cores.muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: textos.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.44,
              color: corValor,
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
