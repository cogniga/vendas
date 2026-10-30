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

    return Padding(
      padding: const EdgeInsets.only(bottom: Espacos.g20),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: Espacos.g12,
        spacing: Espacos.g12,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: textos.headlineMedium),
              if (subtitle != null) ...[
                const SizedBox(height: Espacos.base),
                Text(
                  subtitle!,
                  style: textos.bodyMedium?.copyWith(color: cores.muted),
                ),
              ],
            ],
          ),
          if (actions.isNotEmpty)
            Wrap(
              spacing: Espacos.g8,
              runSpacing: Espacos.g8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: actions,
            ),
        ],
      ),
    );
  }
}
