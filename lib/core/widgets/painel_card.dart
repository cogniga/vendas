import 'package:flutter/material.dart';
import 'package:sales/core/theme/tokens.dart';

/// Painel do protótipo (`.panel`): cabeçalho com título e item à direita,
/// divisória e corpo com padding.
class PainelCard extends StatelessWidget {
  const PainelCard({
    required this.titulo,
    required this.corpo,
    this.trailing,
    this.semPaddingCorpo = false,
    super.key,
  });

  final String titulo;
  final Widget corpo;

  /// Dica, pill ou botão alinhado à direita do título.
  final Widget? trailing;

  /// Quando verdadeiro o corpo ocupa a largura toda (ex.: tabelas).
  final bool semPaddingCorpo;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(Raios.cartao),
        border: Border.all(color: cores.line),
        boxShadow: [
          BoxShadow(
            color: escuro
                ? const Color(0x4D000000)
                : const Color(0x0A101828),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cores.line)),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 6,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          if (semPaddingCorpo)
            corpo
          else
            Padding(
              padding: const EdgeInsets.all(Espacos.paddingPainel),
              child: corpo,
            ),
        ],
      ),
    );
  }
}
