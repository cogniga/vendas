import 'package:flutter/material.dart';
import 'package:sales/core/theme/tokens.dart';

/// Cabeçalho de página: título grande, subtítulo opcional e ações à direita.
///
/// Em telas estreitas as ações descem para a linha de baixo (usa [Wrap]).
class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    this.subtitle,
    this.actions = const [],
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;

    final titulo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: textos.headlineMedium),
        if (subtitle != null) ...[
          // Protótipo `.head p{margin:6px 0 0; max-width:64ch}`.
          const SizedBox(height: 6),
          ConstrainedBox(
            // ~64ch ≈ 64 × 0,5em do corpo 14px (aprox. 512px).
            constraints: const BoxConstraints(maxWidth: 512),
            child: Text(
              subtitle!,
              style: textos.bodyMedium?.copyWith(color: cores.muted),
            ),
          ),
        ],
      ],
    );

    final acoes = actions.isEmpty
        ? null
        : Wrap(
            spacing: Espacos.g8,
            runSpacing: Espacos.g8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: actions,
          );

    // Protótipo `.head{margin-bottom:24px}`.
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Em telas largas: título à esquerda e ações à direita, na mesma
          // linha, alinhadas pela base (`align-items:flex-end`). Em telas
          // estreitas: empilha.
          final estreito = constraints.maxWidth < 600;
          if (acoes == null) return titulo;
          if (estreito) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                titulo,
                const SizedBox(height: Espacos.g12),
                acoes,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: titulo),
              const SizedBox(width: 24),
              acoes,
            ],
          );
        },
      ),
    );
  }
}
