import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sales/core/format/formatos.dart';
import 'package:sales/core/theme/tokens.dart';
import 'package:sales/core/widgets/confirm_delete_button.dart';
import 'package:sales/core/widgets/icon_action.dart';
import 'package:sales/core/widgets/kpi_card.dart';
import 'package:sales/core/widgets/page_header.dart';
import 'package:sales/core/widgets/pill.dart';
import 'package:sales/core/widgets/platform_pill.dart';
import 'package:sales/core/widgets/responsive_list.dart';
import 'package:sales/core/widgets/seletor_segmentado.dart';
import 'package:sales/data/repositorios/pedido_repository.dart';
import 'package:sales/domain/calculos/pedido.dart';
import 'package:sales/domain/calculos/resumo_pedidos.dart';
import 'package:sales/domain/entidades/enums.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/pedido.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:sales/features/composicao/application/composicao_providers.dart'
    as composicao;
import 'package:sales/features/pedidos/application/pedidos_providers.dart';
import 'package:sales/features/pedidos/presentation/pedido_editor.dart';

/// Tela de Pedidos (R5): lista com busca, filtro por plataforma e ações.
class PedidosPage extends ConsumerStatefulWidget {
  const PedidosPage({super.key});

  @override
  ConsumerState<PedidosPage> createState() => _PedidosPageState();
}

class _PedidosPageState extends ConsumerState<PedidosPage> {
  String _busca = '';
  String? _plataformaFiltro;

  /// Período da lista e dos cards (padrão: mês atual).
  PeriodoPedidos _periodo = PeriodoPedidos.mes;
  DateTimeRange? _intervalo;

  /// Escolhe o período; "Período" abre o seletor de datas (de/até).
  Future<void> _mudarPeriodo(PeriodoPedidos novo) async {
    if (novo != PeriodoPedidos.intervalo) {
      setState(() => _periodo = novo);
      return;
    }
    final hoje = DateTime.now();
    final escolhido = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(hoje.year + 1, 12, 31),
      initialDateRange: _intervalo ??
          DateTimeRange(start: DateTime(hoje.year, hoje.month), end: hoje),
      locale: const Locale('pt', 'BR'),
      helpText: 'Período dos pedidos',
      saveText: 'Aplicar',
    );
    if (escolhido == null || !mounted) return;
    setState(() {
      _intervalo = escolhido;
      _periodo = PeriodoPedidos.intervalo;
    });
  }

  Future<void> _abrirEditor(Pedido? pedido) async {
    final salvou = await showDialog<bool>(
      context: context,
      builder: (_) => PedidoEditor(pedido: pedido),
    );
    if ((salvou ?? false) && mounted) {
      _atualizar(pedido?.id);
    }
  }

  /// Invalida tudo que depende dos pedidos (lista, composição, painel/caixa
  /// derivados e o pedido completo do editor).
  void _atualizar(String? id) {
    ref
      ..invalidate(pedidosProvider)
      ..invalidate(composicao.pedidosProvider);
    if (id != null) ref.invalidate(pedidoCompletoProvider(id));
  }

  Future<void> _excluir(Pedido pedido) async {
    try {
      await ref.read(pedidoRepositoryProvider).excluir(pedido.id);
      if (mounted) _atualizar(pedido.id);
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
    final pedidosAsync = ref.watch(pedidosProvider);
    final plataformasAsync = ref.watch(plataformasComFaixasProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: 'Pedidos',
          subtitle: 'Lance o pedido do cliente, os itens e o preço. '
              'O custo sai do cadastro; a taxa é estimada pela plataforma '
              'e você confirma o líquido que a plataforma pagou.',
          actions: [
            SeletorSegmentado<PeriodoPedidos>(
              rotuloSemantico: 'Período',
              selecionado: _periodo,
              onChanged: _mudarPeriodo,
              opcoes: [
                const OpcaoSegmentada(PeriodoPedidos.mes, 'Este mês'),
                const OpcaoSegmentada(PeriodoPedidos.tudo, 'Todo o período'),
                OpcaoSegmentada(
                  PeriodoPedidos.intervalo,
                  _periodo == PeriodoPedidos.intervalo && _intervalo != null
                      ? '${Formatos.data(_intervalo!.start)} – '
                          '${Formatos.data(_intervalo!.end)}'
                      : 'Período…',
                ),
              ],
            ),
            FilledButton.icon(
              onPressed: () => _abrirEditor(null),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Novo pedido'),
            ),
          ],
        ),
        plataformasAsync.when(
          loading: _Carregando.new,
          error: (e, _) => _Erro(
            onTentar: () => ref.invalidate(plataformasComFaixasProvider),
          ),
          data: (plataformas) => pedidosAsync.when(
            loading: _Carregando.new,
            error: (e, _) =>
                _Erro(onTentar: () => ref.invalidate(pedidosProvider)),
            data: (pedidos) => _Conteudo(
              pedidos: filtrarPedidosPorPeriodo(
                pedidos,
                _periodo,
                DateTime.now(),
                de: _intervalo?.start,
                ate: _intervalo?.end,
              ),
              temPedidosNoTotal: pedidos.isNotEmpty,
              plataformas: plataformas,
              busca: _busca,
              plataformaFiltro: _plataformaFiltro,
              onBusca: (v) => setState(() => _busca = v),
              onFiltro: (v) => setState(() => _plataformaFiltro = v),
              onAbrir: _abrirEditor,
              onExcluir: _excluir,
            ),
          ),
        ),
      ],
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({
    required this.pedidos,
    required this.temPedidosNoTotal,
    required this.plataformas,
    required this.busca,
    required this.plataformaFiltro,
    required this.onBusca,
    required this.onFiltro,
    required this.onAbrir,
    required this.onExcluir,
  });

  /// Pedidos já filtrados pelo período.
  final List<Pedido> pedidos;

  /// Se existe algum pedido (em qualquer período), para a mensagem de vazio.
  final bool temPedidosNoTotal;
  final Map<Plataforma, List<FaixaTaxa>> plataformas;
  final String busca;
  final String? plataformaFiltro;
  final ValueChanged<String> onBusca;
  final ValueChanged<String?> onFiltro;
  final void Function(Pedido) onAbrir;
  final void Function(Pedido) onExcluir;

  Plataforma? _plataformaDe(String id) {
    for (final p in plataformas.keys) {
      if (p.id == id) return p;
    }
    return null;
  }

  List<FaixaTaxa> _faixasDe(String id) {
    for (final e in plataformas.entries) {
      if (e.key.id == id) return e.value;
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final q = busca.trim().toLowerCase();
    final lista = pedidos.where((p) {
      final okPlat =
          plataformaFiltro == null || p.plataformaId == plataformaFiltro;
      final okBusca = q.isEmpty || p.cliente.toLowerCase().contains(q);
      return okPlat && okBusca;
    }).toList();

    // Painel único (protótipo `section.panel`): surface, borda 1px line,
    // radius 14, overflow hidden. Dentro, a toolbar no topo (padding 14x20,
    // border-bottom 1px line) e a tabela encostada logo abaixo, sem card
    // interno nem margem solta.
    final resumo = resumirPedidos(lista, {
      for (final e in plataformas.entries) e.key.id: e.value,
    });
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CardsResumo(resumo: resumo),
        const SizedBox(height: Espacos.g16),
        _painelLista(context, lista),
      ],
    );
  }

  Widget _painelLista(BuildContext context, List<Pedido> lista) {
    final cores = context.cores;
    return Container(
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(Raios.cartao),
        border: Border.all(color: cores.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cores.line)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Espacos.g20,
                vertical: 14,
              ),
              child: _Barra(
                plataformas: plataformas.keys.toList(),
                busca: busca,
                plataformaFiltro: plataformaFiltro,
                onBusca: onBusca,
                onFiltro: onFiltro,
              ),
            ),
          ),
          if (lista.isEmpty)
            _Vazio(temPedidos: temPedidosNoTotal)
          else
            ResponsiveList<Pedido>(
              itens: lista,
              semMoldura: true,
              acoes: (p) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconAction(
                    icon: LucideIcons.eye,
                    tooltip: 'Abrir pedido',
                    onPressed: () => onAbrir(p),
                  ),
                  const SizedBox(width: Espacos.g8 - 2),
                  ConfirmDeleteButton(
                    tooltip: 'Excluir pedido',
                    onConfirm: () => onExcluir(p),
                  ),
                ],
              ),
              colunas: [
                ColunaLista<Pedido>(
                  label: 'Pedido',
                  principal: true,
                  builder: (p) => _CelulaPedido(
                    pedido: p,
                    plataforma: _plataformaDe(p.plataformaId),
                  ),
                ),
                ColunaLista<Pedido>(
                  label: 'Itens',
                  builder: (p) => _CelulaItens(pedido: p),
                ),
                ColunaLista<Pedido>(
                  label: 'Venda',
                  alinhamento: Alignment.centerRight,
                  builder: (p) => _CelulaVenda(
                    pedido: p,
                    faixas: _faixasDe(p.plataformaId),
                  ),
                ),
                ColunaLista<Pedido>(
                  label: 'Líquido',
                  alinhamento: Alignment.centerRight,
                  builder: (p) => _CelulaLiquido(
                    pedido: p,
                    faixas: _faixasDe(p.plataformaId),
                  ),
                ),
                ColunaLista<Pedido>(
                  label: 'Lucro',
                  alinhamento: Alignment.centerRight,
                  builder: (p) => _CelulaLucro(
                    pedido: p,
                    faixas: _faixasDe(p.plataformaId),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({
    required this.plataformas,
    required this.busca,
    required this.plataformaFiltro,
    required this.onBusca,
    required this.onFiltro,
  });

  final List<Plataforma> plataformas;
  final String busca;
  final String? plataformaFiltro;
  final ValueChanged<String> onBusca;
  final ValueChanged<String?> onFiltro;

  @override
  Widget build(BuildContext context) {
    final busca = TextField(
      decoration: const InputDecoration(
        hintText: 'Buscar cliente ou nº do pedido',
        prefixIcon: Icon(LucideIcons.search, size: 18),
        isDense: true,
      ),
      onChanged: onBusca,
    );

    final filtro = DropdownButtonFormField<String?>(
      initialValue: plataformaFiltro,
      isExpanded: true,
      decoration: const InputDecoration(isDense: true),
      items: [
        const DropdownMenuItem<String?>(
          child: Text('Todas as plataformas'),
        ),
        for (final p in plataformas)
          DropdownMenuItem<String?>(value: p.id, child: Text(p.nome)),
      ],
      onChanged: onFiltro,
    );

    // Protótipo `.toolbar`: busca ocupa o espaço (`flex:1 1 220px`), filtro
    // com largura automática (`select{width:auto}`); em telas estreitas as
    // duas quebram em linhas (empilham).
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 480) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              busca,
              const SizedBox(height: Espacos.g12),
              filtro,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: busca),
            const SizedBox(width: Espacos.g12),
            SizedBox(width: 240, child: filtro),
          ],
        );
      },
    );
  }
}

class _CelulaPedido extends StatelessWidget {
  const _CelulaPedido({required this.pedido, required this.plataforma});

  final Pedido pedido;
  final Plataforma? plataforma;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final cancelado = pedido.situacao != SituacaoPedido.concluido;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                pedido.cliente,
                style: textos.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (cancelado) ...[
              const SizedBox(width: Espacos.g8),
              Pill(
                pedido.situacao == SituacaoPedido.cancelado
                    ? 'Cancelado'
                    : 'Devolvido',
                tom: pedido.situacao == SituacaoPedido.cancelado
                    ? TomPill.ruim
                    : TomPill.atencao,
              ),
            ],
          ],
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(Formatos.data(pedido.data), style: textos.bodySmall),
            Text(' · ', style: textos.bodySmall),
            if (plataforma != null)
              PlatformPill(nome: plataforma!.nome, cor: plataforma!.cor),
          ],
        ),
      ],
    );
  }
}

class _CelulaItens extends StatelessWidget {
  const _CelulaItens({required this.pedido});

  final Pedido pedido;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final n = pedido.itens.fold<int>(0, (s, i) => s + i.quantidade);
    final r = calcularPedido(pedido, const []);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$n ${n == 1 ? 'item' : 'itens'}'),
        const SizedBox(height: 3),
        Text(
          Formatos.abelinhas(r.abelinhasPedido.toDouble()),
          style: textos.bodySmall,
        ),
      ],
    );
  }
}

class _CelulaVenda extends StatelessWidget {
  const _CelulaVenda({required this.pedido, required this.faixas});

  final Pedido pedido;
  final List<FaixaTaxa> faixas;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final r = calcularPedido(pedido, faixas);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(Formatos.moedaDecimal(pedido.precoVenda)),
        const SizedBox(height: 3),
        Text(
          'taxa ${Formatos.moedaDecimal(r.taxaEfetiva)}',
          style: textos.bodySmall,
        ),
      ],
    );
  }
}

class _CelulaLiquido extends StatelessWidget {
  const _CelulaLiquido({required this.pedido, required this.faixas});

  final Pedido pedido;
  final List<FaixaTaxa> faixas;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final r = calcularPedido(pedido, faixas);
    final estimado = pedido.liquidoInformado == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(Formatos.moedaDecimal(r.liquido)),
            if (estimado) ...[
              const SizedBox(width: Espacos.g8),
              const Pill('est.'),
            ],
          ],
        ),
        const SizedBox(height: 3),
        Text(
          'custo ${Formatos.moedaDecimal(r.custo)}',
          style: textos.bodySmall,
        ),
      ],
    );
  }
}

class _CelulaLucro extends StatelessWidget {
  const _CelulaLucro({required this.pedido, required this.faixas});

  final Pedido pedido;
  final List<FaixaTaxa> faixas;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final r = calcularPedido(pedido, faixas);
    final negativo = r.lucro < Decimal.zero;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          Formatos.moedaDecimal(r.lucro),
          style: textos.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: negativo ? cores.bad : cores.good,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '${Formatos.percentualFracao(r.margem.toDouble())} da venda',
          style: textos.bodySmall,
        ),
      ],
    );
  }
}

class _Carregando extends StatelessWidget {
  const _Carregando();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(Espacos.g20),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _Erro extends StatelessWidget {
  const _Erro({required this.onTentar});

  final VoidCallback onTentar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Espacos.g20),
      child: Column(
        children: [
          const Text('Não foi possível carregar os pedidos.'),
          const SizedBox(height: Espacos.g12),
          OutlinedButton(
            onPressed: onTentar,
            child: const Text('Tentar de novo'),
          ),
        ],
      ),
    );
  }
}

/// Cards de resumo do que está listado (período + busca + plataforma).
/// Líquido e lucro em destaque, como no Painel (D11).
class _CardsResumo extends StatelessWidget {
  const _CardsResumo({required this.resumo});

  final ResumoPedidos resumo;

  @override
  Widget build(BuildContext context) {
    final r = resumo;
    final foraDoResultado = r.quantidadeLancados - r.quantidade;
    return KpiRow(
      cartoes: [
        KpiCard(
          label: 'Líquido das vendas',
          value: Formatos.moedaDecimal(r.liquido),
          sub: 'pago pelas plataformas',
          destaque: true,
          valorNegativo: r.liquido < Decimal.zero,
        ),
        KpiCard(
          label: 'Lucro total',
          value: Formatos.moedaDecimal(r.lucro),
          sub: 'margem ${Formatos.percentualFracao(r.margem.toDouble())}',
          destaque: true,
          valorNegativo: r.lucro < Decimal.zero,
        ),
        KpiCard(
          label: 'Custo total',
          value: Formatos.moedaDecimal(r.custo),
          sub: 'produto + embalagem',
        ),
        KpiCard(
          label: 'Pedidos',
          value: '${r.quantidade}',
          sub: foraDoResultado > 0
              ? '+ $foraDoResultado cancelado(s)/devolvido(s)'
              : 'no período',
        ),
      ],
    );
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio({required this.temPedidos});

  final bool temPedidos;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    // Protótipo `.empty{padding:32px 16px;text-align:center;color:muted}`.
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 32,
        horizontal: Espacos.g16,
      ),
      child: Center(
        child: Text(
          temPedidos
              ? 'Nenhum pedido encontrado com esse filtro.'
              : 'Nenhum pedido. Use "Novo pedido" para lançar o primeiro.',
          textAlign: TextAlign.center,
          style: TextStyle(color: cores.muted),
        ),
      ),
    );
  }
}
