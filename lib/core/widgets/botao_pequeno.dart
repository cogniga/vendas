import 'package:flutter/material.dart';
import 'package:sales/core/theme/tokens.dart';

/// Botão pequeno estilo `.btn.sm` do protótipo: fundo surface, borda 1px line,
/// radius 8, padding 5x10, texto 12,5/500 ink e hover em surface-2.
class BotaoPequeno extends StatelessWidget {
  const BotaoPequeno({
    required this.rotulo,
    required this.onPressed,
    this.tooltip,
    super.key,
  });

  final String rotulo;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final botao = TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (estados) => estados.contains(WidgetState.hovered)
              ? cores.surface2
              : cores.surface,
        ),
        foregroundColor: WidgetStatePropertyAll(cores.ink),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        ),
        minimumSize: const WidgetStatePropertyAll(Size.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Raios.controle),
            side: BorderSide(color: cores.line),
          ),
        ),
      ),
      child: Text(rotulo),
    );
    final mensagem = tooltip;
    if (mensagem == null) return botao;
    return Tooltip(message: mensagem, child: botao);
  }
}
