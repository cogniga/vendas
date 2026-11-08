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
import 'package:sales/core/widgets/pill.dart';
import 'package:sales/core/widgets/responsive_list.dart';
import 'package:sales/data/repositorios/compra_insumo_repository.dart';
import 'package:sales/data/repositorios/empresa_atual_provider.dart';
import 'package:sales/domain/calculos/decimais.dart';
import 'package:sales/domain/entidades/compra_insumo.dart';
import 'package:sales/domain/entidades/destino.dart';
import 'package:sales/features/compras_insumos/application/insumos_providers.dart';
import 'package:sales/features/compras_insumos/presentation/compra_form.dart';

/// Tela Compras de insumos (R7): KPI do total, lista por data e formulário em
/// painel lateral com valor unitário ao vivo.
class InsumosPage extends ConsumerStatefulWidget {
  const InsumosPage({super.key});

  @override
  ConsumerState<InsumosPage> createState() => _InsumosPageState();
}

class _InsumosPageState extends ConsumerState<InsumosPage> {
  Future<void> _novo() async {
    final empresa = await ref.read(empresaAtualProvider.future);
    if (empresa == null || !mounted) return;
    final destinos = ref.read(destinosProvider).valueOrNull ?? const [];
    final salvou = await abrirCompraForm(
      context,
      empresaId: empresa.id,
      destinos: destinos,
    );
    if ((salvou ?? false) && mounted) ref.invalidate(insumosProvider);
  }

  Future<void> _editar(CompraInsumo compra) async {
    final destinos = ref.read(destinosProvider).valueOrNull ?? const [];
    final salvou = await abrirCompraForm(
      context,
      empresaId: compra.empresaId,
      compra: compra,
      destinos: destinos,
    );
    if ((salvou ?? false) && mounted) ref.invalidate(insumosProvider);
  }

  Future<void> _excluir(CompraInsumo compra) async {
    try {
      await ref.read(compraInsumoRepositoryProvider).excluir(compra.id);
      if (mounted) ref.invalidate(insumosProvider);
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
    final insumosAsync = ref.watch(insumosProvider);
    final destinos = ref.watch(destinosProvider).valueOrNull ?? const [];

    final compras = insumosAsync.valueOrNull ?? const <CompraInsumo>[];
    final total = compras.fold<Decimal>(
      Decimal.zero,
      (soma, c) => soma + c.valorTotal,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: 'Compras de insumos',
          subtitle: 'Caixas, etiquetas, papel de impressão, fitas e outros '
              'materiais. O valor unitário fica disponível para escolher '
              'como embalagem na composição de custo.',
          actions: [
            FilledButton.icon(
              onPressed: _novo,
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Registrar compra'),
            ),
          ],
        ),
        KpiRow(
          cartoes: [
            KpiCard(
              label: 'Total em insumos',
              value: Formatos.moedaDecimal(total),
              sub: '${compras.length} compra(s)',
            ),
          ],
        ),
        const SizedBox(height: Espacos.g16),
        EstadoLista<CompraInsumo>(
          estado: insumosAsync,
          mensagemVazia: 'Nenhuma compra registrada.',
          aoTentarDeNovo: () => ref.invalidate(insumosProvider),
          comDados: (lista) => ResponsiveList<CompraInsumo>(
            itens: lista,
            colunas: _colunas(destinos),
            acoes: (c) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconAction(
                  icon: LucideIcons.pencil,
                  tooltip: 'Editar compra',
                  onPressed: () => _editar(c),
                ),
                ConfirmDeleteButton(
                  tooltip: 'Excluir compra',
                  onConfirm: () => _excluir(c),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<ColunaLista<CompraInsumo>> _colunas(List<Destino> destinos) {
    String nomeDestino(String? id) {
      if (id == null) return '—';
      for (final d in destinos) {
        if (d.id == id) return d.nome;
      }
      return '—';
    }

    return [
      ColunaLista<CompraInsumo>(
        label: 'Compra',
        principal: true,
        builder: (c) => _CelulaCompra(compra: c),
      ),
      ColunaLista<CompraInsumo>(
        label: 'Quantidade',
        builder: (c) => _CelulaQuantidade(compra: c),
      ),
      ColunaLista<CompraInsumo>(
        label: 'Valor',
        alinhamento: Alignment.centerRight,
        builder: (c) => _CelulaValor(compra: c),
      ),
      ColunaLista<CompraInsumo>(
        label: 'Pago com',
        builder: (c) => _CelulaPagoCom(
          compra: c,
          destino: nomeDestino(c.destinoId),
        ),
      ),
    ];
  }
}

/// Célula principal: produto, data, pill do tipo e descrição.
class _CelulaCompra extends StatelessWidget {
  const _CelulaCompra({required this.compra});

  final CompraInsumo compra;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(compra.produto, style: textos.titleMedium),
        const SizedBox(height: Espacos.base),
        Wrap(
          spacing: Espacos.g8,
          runSpacing: Espacos.base,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              Formatos.data(compra.data),
              style: textos.bodySmall?.copyWith(color: cores.muted),
            ),
            Pill(compra.tipo),
            if (compra.descricao.isNotEmpty)
              Text(
                compra.descricao,
                style: textos.bodySmall?.copyWith(color: cores.muted),
              ),
          ],
        ),
      ],
    );
  }
}

/// Célula de quantidade: total de itens e pacotes.
class _CelulaQuantidade extends StatelessWidget {
  const _CelulaQuantidade({required this.compra});

  final CompraInsumo compra;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${compra.itens} itens'),
        const SizedBox(height: Espacos.base),
        Text(
          '${compra.pacotes} pacote(s)',
          style: textos.bodySmall?.copyWith(color: cores.muted),
        ),
      ],
    );
  }
}

/// Célula de valor: total e valor por item.
class _CelulaValor extends StatelessWidget {
  const _CelulaValor({required this.compra});

  final CompraInsumo compra;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final unit = compra.itens == 0
        ? Decimal.zero
        : compra.valorTotal.dividir(Decimal.fromInt(compra.itens));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(Formatos.moedaDecimal(compra.valorTotal)),
        const SizedBox(height: Espacos.base),
        Text(
          '${Formatos.moedaDecimal(unit)} por item',
          style: textos.bodySmall?.copyWith(color: cores.muted),
        ),
      ],
    );
  }
}

/// Célula de destino: nome do destino e origem (caixa).
class _CelulaPagoCom extends StatelessWidget {
  const _CelulaPagoCom({required this.compra, required this.destino});

  final CompraInsumo compra;
  final String destino;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(destino),
        const SizedBox(height: Espacos.base),
        Text(
          compra.destinoId != null ? 'sai do caixa' : 'fora do caixa',
          style: textos.bodySmall?.copyWith(color: cores.muted),
        ),
      ],
    );
  }
}
