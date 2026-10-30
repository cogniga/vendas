import 'package:flutter/material.dart';
import 'package:sales/core/theme/tokens.dart';

/// Botão de ação apenas com ícone.
///
/// Acessibilidade obrigatória: sempre com [Tooltip] e `Semantics(label:)`
/// usando [tooltip] como descrição. [danger] pinta o ícone com a cor de erro.
class IconAction extends StatelessWidget {
  const IconAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.danger = false,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final cor = danger ? cores.bad : cores.muted;

    return Semantics(
      label: tooltip,
      button: true,
      child: Tooltip(
        message: tooltip,
        child: IconButton(
          icon: Icon(icon, size: 18, color: cor),
          onPressed: onPressed,
          splashRadius: 20,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
