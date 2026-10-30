import 'package:flutter/material.dart';
import 'package:sales/core/theme/tokens.dart';

/// Uma linha rótulo/valor de um [Ledger].
class LinhaLedger {
  const LinhaLedger(this.rotulo, this.valor, {this.destaque = false});

  final String rotulo;
  final String valor;

  /// Destaca a linha (ex.: subtotais relevantes) sem ser o total final.
  final bool destaque;
}

/// Bloco chave/valor (resumo financeiro) com uma linha de total destacada.
class Ledger extends StatelessWidget {
  const Ledger({required this.linhas, this.total, super.key});

  final List<LinhaLedger> linhas;

  /// Linha final destacada (ex.: "Lucro"). Opcional.
  final LinhaLedger? total;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final l in linhas)
          _linha(
            context,
            l,
            estiloRotulo: l.destaque
                ? textos.bodyMedium?.copyWith(fontWeight: FontWeight.w600)
                : textos.bodyMedium?.copyWith(color: cores.muted),
            estiloValor: textos.bodyMedium?.copyWith(
              fontWeight: l.destaque ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        if (total != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Espacos.g8),
            child: Divider(height: 1, color: cores.line),
          ),
          _linha(
            context,
            total!,
            estiloRotulo: textos.titleMedium,
            estiloValor: textos.titleMedium?.copyWith(color: cores.accent),
          ),
        ],
      ],
    );
  }

  Widget _linha(
    BuildContext context,
    LinhaLedger l, {
    TextStyle? estiloRotulo,
    TextStyle? estiloValor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Espacos.base),
      child: Row(
        children: [
          Expanded(child: Text(l.rotulo, style: estiloRotulo)),
          const SizedBox(width: Espacos.g12),
          Text(l.valor, style: estiloValor),
        ],
      ),
    );
  }
}
