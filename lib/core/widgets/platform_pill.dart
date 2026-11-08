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
    final tinta = context.cores.muted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: context.cores.surface2,
        borderRadius: BorderRadius.circular(Raios.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bolinha com a cor própria da plataforma (dot 8px do protótipo).
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: base, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            nome,
            style: TextStyle(
              color: tinta,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
}
