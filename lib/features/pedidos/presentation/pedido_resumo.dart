import 'package:flutter/material.dart';
import 'package:sales/core/theme/tokens.dart';
import 'package:sales/core/widgets/ledger.dart';
import 'package:sales/core/widgets/pill.dart';

/// Resumo financeiro do editor de pedido (coluna direita do protótipo).
///
/// Só apresenta valores já calculados e formatados pelo editor; nenhum
/// cálculo de negócio acontece aqui.
class PedidoResumo extends StatelessWidget {
  const PedidoResumo({
    required this.mercadoria,
    required this.extras,
    required this.custoTotal,
    required this.linhasAbelinhas,
    required this.totalAbelinhas,
    required this.rotuloValorAbelinha,
    required this.valorAbelinhas,
    required this.precoVenda,
    required this.rotuloTaxa,
    required this.taxaEstimada,
    required this.liquidoEstimado,
    required this.liquidoConsiderado,
    required this.liquidoInformado,
    required this.taxaEfetiva,
    required this.lucro,
    required this.lucroNegativo,
    required this.margem,
    this.avisoPreco,
    this.avisoLiquido,
    super.key,
  });

  final String mercadoria;
  final String extras;
  final String custoTotal;

  /// Pares (rótulo, valor) de abelinhas por item.
  final List<(String, String)> linhasAbelinhas;
  final String totalAbelinhas;
  final String rotuloValorAbelinha;
  final String valorAbelinhas;
  final String precoVenda;
  final String rotuloTaxa;
  final String taxaEstimada;
  final String liquidoEstimado;
  final String liquidoConsiderado;

  /// `true` quando o líquido veio da plataforma (pill "informado").
  final bool liquidoInformado;
  final String taxaEfetiva;
  final String lucro;
  final bool lucroNegativo;
  final String margem;

  /// Aviso informativo sobre o preço preenchido pelo kit.
  final String? avisoPreco;

  /// Aviso de divergência entre líquido informado e estimado.
  final String? avisoLiquido;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final subtitulo = textos.bodySmall;

    return Container(
      padding: const EdgeInsets.all(Espacos.g20),
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(Raios.cartao),
        border: Border.all(color: cores.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _titulo(context, 'Custo do pedido'),
          Ledger(
            linhas: [
              LinhaLedger('Mercadoria', mercadoria),
              LinhaLedger('Embalagem + impressão + outros', extras),
            ],
          ),
          _caixaCinza(context, 'Custo total', custoTotal),
          const SizedBox(height: Espacos.g16),
          _titulo(context, 'Abelinhas do pedido'),
          Ledger(
            linhas: [
              for (final l in linhasAbelinhas) LinhaLedger(l.$1, l.$2),
              LinhaLedger('Total de abelinhas', totalAbelinhas, destaque: true),
            ],
          ),
          const SizedBox(height: Espacos.g16),
          _titulo(context, 'Venda'),
          Ledger(
            linhas: [
              LinhaLedger('Preço de venda', precoVenda),
              LinhaLedger(rotuloTaxa, taxaEstimada),
              // Logo abaixo da estimada, para comparar as duas (pedido do
              // usuário; no protótipo vinha depois do líquido considerado).
              LinhaLedger('Taxa efetiva', taxaEfetiva),
              LinhaLedger('Líquido estimado', liquidoEstimado),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Espacos.base),
            child: Row(
              children: [
                const Expanded(child: Text('Líquido considerado')),
                Pill(
                  liquidoInformado ? 'informado' : 'estimado',
                  tom: liquidoInformado ? TomPill.bom : TomPill.neutro,
                ),
                const SizedBox(width: Espacos.g8),
                Text(
                  liquidoConsiderado,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          _caixaCinza(
            context,
            'Lucro do pedido',
            lucro,
            corValor: lucroNegativo ? cores.bad : cores.good,
          ),
          const SizedBox(height: Espacos.g8),
          Text(
            'Margem sobre a venda: $margem',
            style: subtitulo?.copyWith(color: cores.muted),
          ),
          if (avisoPreco != null)
            _aviso(context, avisoPreco!, cores.accentSoft, cores.accent),
          if (avisoLiquido != null)
            _aviso(context, avisoLiquido!, cores.warnSoft, cores.warn),
        ],
      ),
    );
  }

  Widget _titulo(BuildContext context, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Espacos.g8),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _caixaCinza(
    BuildContext context,
    String rotulo,
    String valor, {
    Color? corValor,
  }) {
    final cores = context.cores;
    return Container(
      margin: const EdgeInsets.only(top: Espacos.g8),
      padding: const EdgeInsets.symmetric(
        horizontal: Espacos.g12,
        vertical: Espacos.g12,
      ),
      decoration: BoxDecoration(
        color: cores.surface2,
        borderRadius: BorderRadius.circular(Raios.controle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              rotulo,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            valor,
            style: TextStyle(fontWeight: FontWeight.w600, color: corValor),
          ),
        ],
      ),
    );
  }

  Widget _aviso(BuildContext context, String texto, Color fundo, Color tinta) {
    return Container(
      margin: const EdgeInsets.only(top: Espacos.g12),
      padding: const EdgeInsets.all(Espacos.g12),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(Raios.controle),
      ),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: tinta),
      ),
    );
  }
}
