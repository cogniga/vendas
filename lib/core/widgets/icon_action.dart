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
    // Visual `.iconbtn` do protótipo: quadrado 34x34, borda 1px line,
    // radius 8, fundo surface, cor do ícone muted; hover → surface-2
    // (e, quando danger, hover → fundo bad-soft, cor bad).
    final corIcone = danger ? cores.bad : cores.muted;

    return Semantics(
      label: tooltip,
      button: true,
      child: Tooltip(
        message: tooltip,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Material(
            color: cores.surface,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: cores.line),
              borderRadius: BorderRadius.circular(Raios.controle),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              hoverColor: danger ? cores.badSoft : cores.surface2,
              child: Center(child: Icon(icon, size: 18, color: corIcone)),
            ),
          ),
        ),
      ),
    );
  }
}
