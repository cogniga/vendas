import 'package:flutter/material.dart';
import 'package:sales/core/theme/tokens.dart';

/// Etiqueta de plataforma com a cor própria (hex) da plataforma.
///
/// Aceita cores no formato `#RRGGBB` ou `#AARRGGBB`; se o texto não for um hex
/// válido, cai na cor de destaque do tema.
class PlatformPill extends StatelessWidget {
  const PlatformPill({required this.nome, required this.cor, super.key});

  final String nome;
  final String cor;

  @override
  Widget build(BuildContext context) {
    final base = _parseCor(cor) ?? context.cores.accent;
    final tinta = _contraste(base);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(Raios.pill),
        border: Border.all(color: base.withValues(alpha: 0.5)),
      ),
      child: Text(
        nome,
        style: TextStyle(
          color: tinta,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Color? _parseCor(String hex) {
    var limpo = hex.trim().replaceAll('#', '').toUpperCase();
    if (limpo.length == 6) limpo = 'FF$limpo';
    if (limpo.length != 8) return null;
    final valor = int.tryParse(limpo, radix: 16);
    return valor == null ? null : Color(valor);
  }

  /// Escurece a cor base para garantir legibilidade do texto sobre o fundo
  /// translúcido.
  static Color _contraste(Color base) {
    final hsl = HSLColor.fromColor(base);
    return hsl
        .withLightness((hsl.lightness - 0.25).clamp(0.0, 1.0))
        .toColor();
  }
}
