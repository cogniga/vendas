import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sales/core/format/formatos.dart';
import 'package:sales/core/theme/tokens.dart';
import 'package:sales/core/widgets/confirm_delete_button.dart';
import 'package:sales/core/widgets/estado_lista.dart';
import 'package:sales/core/widgets/icon_action.dart';
import 'package:sales/core/widgets/kpi_card.dart';
import 'package:sales/core/widgets/page_header.dart';
import 'package:sales/core/widgets/responsive_list.dart';
import 'package:sales/data/repositorios/empresa_atual_provider.dart';
import 'package:sales/data/repositorios/investimento_repository.dart';
import 'package:sales/domain/entidades/destino.dart';
import 'package:sales/domain/entidades/investimento.dart';
import 'package:sales/features/investimento/application/investimento_providers.dart';
import 'package:sales/features/investimento/presentation/investimento_form.dart';

/// Tela de Investimento (R8): KPIs (total investido + 3 maiores
/// distribuidores), lista por data desc e formulário em painel lateral.
class InvestimentoPage extends ConsumerStatefulWidget {
  const InvestimentoPage({super.key});

  @override
  ConsumerState<InvestimentoPage> createState() => _InvestimentoPageState();
}

class _InvestimentoPageState extends ConsumerState<InvestimentoPage> {
  Future<void> _novo(List<Destino> destinos) async {
    final empresa = await ref.read(empresaAtualProvider.future);
    if (empresa == null || !mounted) return;
    final salvou = await abrirInvestimentoForm(
      context,
      empresaId: empresa.id,
      destinos: destinos,
    );
    if ((salvou ?? false) && mounted) ref.invalidate(investimentosProvider);
  }

  Future<void> _editar(Investimento i, List<Destino> destinos) async {
    final salvou = await abrirInvestimentoForm(
      context,
      empresaId: i.empresaId,
      destinos: destinos,
      investimento: i,
    );
    if ((salvou ?? false) && mounted) ref.invalidate(investimentosProvider);
  }

  Future<void> _excluir(Investimento i) async {
    try {
      await ref.read(investimentoRepositoryProvider).excluir(i.id);
      if (mounted) ref.invalidate(investimentosProvider);
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível excluir. Tente de novo.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final investimentosAsync = ref.watch(investimentosProvider);
    final destinos = ref.watch(destinosProvider).valueOrNull ?? const [];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: 'Investimento',
          subtitle: 'Compras de mercadoria para revenda, por distribuidor. '
              'Cada lançamento pode sair de um destino do caixa.',
          actions: [
            FilledButton.icon(
              onPressed: () => _novo(destinos),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Registrar investimento'),
            ),
          ],
        ),
        EstadoLista<Investimento>(
          estado: investimentosAsync,
          mensagemVazia: 'Nenhum investimento registrado. Use '
              '“Registrar investimento” para lançar o primeiro.',
          aoTentarDeNovo: () => ref.invalidate(investimentosProvider),
          acaoVazio: FilledButton.icon(
            onPressed: () => _novo(destinos),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('Registrar investimento'),
          ),
          comDados: (investimentos) => _Conteudo(
            investimentos: investimentos,
            destinos: destinos,
            onEditar: _editar,
            onExcluir: _excluir,
          ),
        ),
      ],
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({
    required this.investimentos,
    required this.destinos,
    required this.onEditar,
    required this.onExcluir,
  });

  final List<Investimento> investimentos;
  final List<Destino> destinos;
  final void Function(Investimento, List<Destino>) onEditar;
  final void Function(Investimento) onExcluir;

  Destino? _destinoDe(String? id) {
    if (id == null) return null;
    for (final d in destinos) {
      if (d.id == id) return d;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final total = investimentos.fold<Decimal>(
      Decimal.zero,
      (soma, i) => soma + i.valor,
    );

    // Soma por distribuidor (maiores primeiro).
    final porDistribuidor = <String, Decimal>{};
    for (final i in investimentos) {
      porDistribuidor[i.distribuidor] =
          (porDistribuidor[i.distribuidor] ?? Decimal.zero) + i.valor;
    }
    final maiores = porDistribuidor.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    String percentualDoTotal(Decimal valor) {
      if (total == Decimal.zero) return '—';
      return '${Formatos.percentualFracao((valor / total).toDouble())} '
          'do total';
    }

    final ordenados = [...investimentos]
      ..sort((a, b) => b.data.compareTo(a.data));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KpiRow(
          cartoes: [
            KpiCard(
              label: 'Total investido',
              value: Formatos.moedaDecimal(total),
              sub: '${investimentos.length} lançamento(s)',
            ),
            for (final e in maiores.take(3))
              KpiCard(
                label: e.key,
                value: Formatos.moedaDecimal(e.value),
                sub: percentualDoTotal(e.value),
              ),
          ],
        ),
        const SizedBox(height: Espacos.g16),
        ResponsiveList<Investimento>(
          itens: ordenados,
          acoes: (i) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconAction(
                icon: LucideIcons.pencil,
                tooltip: 'Editar investimento',
                onPressed: () => onEditar(i, destinos),
              ),
              ConfirmDeleteButton(
                tooltip: 'Excluir investimento',
                onConfirm: () => onExcluir(i),
              ),
            ],
          ),
          colunas: [
            ColunaLista<Investimento>(
              label: 'Distribuidor',
              principal: true,
              builder: (i) => _CelulaDistribuidor(investimento: i),
            ),
            ColunaLista<Investimento>(
              label: 'Valor',
              alinhamento: Alignment.centerRight,
              builder: (i) => _CelulaValor(
                investimento: i,
                percentual: percentualDoTotal(i.valor),
              ),
            ),
            ColunaLista<Investimento>(
              label: 'Pago com',
              builder: (i) => _CelulaPagoCom(destino: _destinoDe(i.destinoId)),
            ),
          ],
        ),
      ],
    );
  }
}

class _CelulaDistribuidor extends StatelessWidget {
  const _CelulaDistribuidor({required this.investimento});

  final Investimento investimento;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final partes = <String>[
      Formatos.data(investimento.data),
      if (investimento.nota.isNotEmpty) 'nota ${investimento.nota}',
      if (investimento.obs.isNotEmpty) investimento.obs,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(investimento.distribuidor, style: textos.titleMedium),
        const SizedBox(height: Espacos.base),
        Text(
          partes.join(' · '),
          style: textos.bodySmall?.copyWith(color: cores.muted),
        ),
      ],
    );
  }
}

class _CelulaValor extends StatelessWidget {
  const _CelulaValor({required this.investimento, required this.percentual});

  final Investimento investimento;
  final String percentual;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          Formatos.moedaDecimal(investimento.valor),
          style: textos.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: Espacos.base),
        Text(
          percentual,
          style: textos.bodySmall?.copyWith(color: cores.muted),
        ),
      ],
    );
  }
}

class _CelulaPagoCom extends StatelessWidget {
  const _CelulaPagoCom({required this.destino});

  final Destino? destino;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(destino?.nome ?? '—'),
        const SizedBox(height: Espacos.base),
        Text(
          destino != null ? 'sai do caixa' : 'fora do caixa',
          style: textos.bodySmall?.copyWith(color: cores.muted),
        ),
      ],
    );
  }
}
