import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sales/core/format/formatos.dart';
import 'package:sales/core/router/rotas.dart';
import 'package:sales/core/widgets/grade_paineis.dart';
import 'package:sales/core/widgets/kpi_card.dart';
import 'package:sales/core/widgets/page_header.dart';
import 'package:sales/core/widgets/seletor_segmentado.dart';
import 'package:sales/domain/calculos/decimais.dart';
import 'package:sales/domain/calculos/painel.dart';
import 'package:sales/features/painel/application/painel_providers.dart';
import 'package:sales/features/painel/presentation/painel_paineis.dart';
import 'package:sales/features/pedidos/application/pedidos_providers.dart';
import 'package:sales/features/pedidos/presentation/pedido_editor.dart';

/// Tela do Painel: período, KPIs e quatro painéis de resumo.
class PainelPage extends ConsumerWidget {
  const PainelPage({super.key});

  Future<void> _novoPedido(BuildContext context, WidgetRef ref) async {
    final salvou = await showDialog<bool>(
      context: context,
      builder: (_) => const PedidoEditor(),
    );
    if ((salvou ?? false) && context.mounted) {
      ref.invalidate(pedidosProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dados = ref.watch(dadosPainelProvider);
    final periodo = ref.watch(periodoPainelProvider);
    final erro = ref.watch(dadosBrutosPainelProvider).hasError;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: 'Painel',
          subtitle: 'Resumo das vendas lançadas, do dinheiro sacado e dos '
              'pontos de atenção.',
          actions: [
            SeletorSegmentado<PeriodoPainel>(
              rotuloSemantico: 'Período',
              selecionado: periodo,
              onChanged: (v) =>
                  ref.read(periodoPainelProvider.notifier).state = v,
              opcoes: const [
                OpcaoSegmentada(PeriodoPainel.mes, 'Este mês'),
                OpcaoSegmentada(PeriodoPainel.tudo, 'Todo o período'),
              ],
            ),
            FilledButton(
              onPressed: () => _novoPedido(context, ref),
              child: const Text('Novo pedido'),
            ),
          ],
        ),
        if (dados != null)
          _Conteudo(dados: dados)
        else if (erro)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                const Text('Não foi possível carregar o painel.'),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ref.invalidate(dadosBrutosPainelProvider),
                  child: const Text('Tentar de novo'),
                ),
              ],
            ),
          )
        else
          const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.dados});

  final DadosPainel dados;

  String _pc(Decimal parte, Decimal total) => total == zero
      ? '—'
      : Formatos.percentualFracao(parte.dividir(total).toDouble());

  @override
  Widget build(BuildContext context) {
    final k = dados.kpis;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KpiRow(
          cartoes: [
            KpiCard(
              label: 'Faturamento',
              value: Formatos.moedaDecimal(k.faturamento),
              sub: '${dados.qtdPedidos} pedido(s)',
            ),
            KpiCard(
              label: 'Taxas das plataformas',
              value: Formatos.moedaDecimal(k.taxas),
              sub: '${_pc(k.taxas, k.faturamento)} do faturamento',
            ),
            KpiCard(
              label: 'Líquido recebido',
              value: Formatos.moedaDecimal(k.liquido),
              sub: 'vai para a carteira',
            ),
            KpiCard(
              label: 'Custo dos pedidos',
              value: Formatos.moedaDecimal(k.custo),
              sub: 'produto + embalagem',
            ),
            KpiCard(
              label: 'Lucro',
              value: Formatos.moedaDecimal(k.lucro),
              valorNegativo: k.lucro < zero,
              sub: 'margem ${_pc(k.lucro, k.faturamento)}',
            ),
          ],
        ),
        const SizedBox(height: 16),
        GradePaineis(
          filhos: [
            PainelVendasPlataforma(vendas: dados.vendas),
            PainelAtencao(pontos: dados.pontos),
            PainelCaixa(
              destinos: dados.destinosComSaldo,
              totalSacado: dados.totalSacado,
              onAbrirCaixa: () => context.go(Rotas.caixa),
            ),
            PainelTopItens(itens: dados.topItens),
          ],
        ),
      ],
    );
  }
}
