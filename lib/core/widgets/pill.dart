import 'package:flutter/material.dart';
import 'package:sales/core/theme/tokens.dart';

/// Tom visual de uma [Pill], mapeado para os pares de cor do tema.
enum TomPill { neutro, bom, atencao, ruim, destaque }

/// Etiqueta compacta de estado (lucro/atenção/prejuízo etc.).
///
/// `bom` → good/goodSoft, `atencao` → warn/warnSoft, `ruim` → bad/badSoft,
/// `destaque` → accent/accentSoft, `neutro` → ink/surface2.
class Pill extends StatelessWidget {
  const Pill(this.texto, {this.tom = TomPill.neutro, super.key});

  final String texto;
  final TomPill tom;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final (fundo, tinta) = switch (tom) {
      TomPill.bom => (cores.goodSoft, cores.good),
      TomPill.atencao => (cores.warnSoft, cores.warn),
      TomPill.ruim => (cores.badSoft, cores.bad),
      TomPill.destaque => (cores.accentSoft, cores.accent),
      TomPill.neutro => (cores.surface2, cores.ink),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(Raios.pill),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: tinta,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
