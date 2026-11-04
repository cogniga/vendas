import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sales/core/format/formatos.dart';
import 'package:sales/core/theme/tokens.dart';
import 'package:sales/core/widgets/abelinhas.dart';
import 'package:sales/core/widgets/code_chip.dart';
import 'package:sales/core/widgets/confirm_delete_button.dart';
import 'package:sales/core/widgets/estado_lista.dart';
import 'package:sales/core/widgets/icon_action.dart';
import 'package:sales/core/widgets/page_header.dart';
import 'package:sales/core/widgets/pill.dart';
import 'package:sales/core/widgets/responsive_list.dart';
import 'package:sales/data/repositorios/empresa_atual_provider.dart';
import 'package:sales/domain/calculos/abelinhas.dart';
import 'package:sales/domain/entidades/faixa_abelinha.dart';
import 'package:sales/domain/entidades/produto.dart';
import 'package:sales/features/produtos/application/produto_form_controller.dart';
import 'package:sales/features/produtos/application/produtos_providers.dart';
import 'package:sales/features/produtos/presentation/produto_form.dart';

/// Tela de Produtos (R3): lista com busca, filtro por categoria, contador e
/// ações de editar/excluir. Abre o formulário num painel lateral.
class ProdutosPage extends ConsumerStatefulWidget {
  const ProdutosPage({super.key});

  @override
  ConsumerState<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends ConsumerState<ProdutosPage> {
  String _busca = '';
  String _categoria = '';

  List<Produto> _filtrar(List<Produto> produtos) {
    final termo = _busca.trim().toLowerCase();
    return produtos.where((p) {
      final casaCategoria = _categoria.isEmpty || p.categoria == _categoria;
      if (!casaCategoria) return false;
      if (termo.isEmpty) return true;
      return p.nome.toLowerCase().contains(termo) ||
          p.codigo.toLowerCase().contains(termo) ||
          p.marca.toLowerCase().contains(termo) ||
          p.fornecedor.toLowerCase().contains(termo);
    }).toList();
  }

  Future<void> _novo(List<FaixaAbelinha> faixas, Decimal v) async {
    final empresa = await ref.read(empresaAtualProvider.future);
    if (empresa == null || !mounted) return;
    await abrirProdutoForm(
      context,
      empresaId: empresa.id,
      faixas: faixas,
      valorAbelinha: v,
    );
  }

  Future<void> _editar(
    Produto produto,
    List<FaixaAbelinha> faixas,
    Decimal v,
  ) async {
    await abrirProdutoForm(
      context,
      empresaId: produto.empresaId,
      produto: produto,
      faixas: faixas,
      valorAbelinha: v,
    );
  }

  Future<void> _excluir(Produto produto) async {
    final controller = ref.read(produtoFormControllerProvider.notifier);
    final kits = await controller.kitsQueUsam(produto.id);
    if (!mounted) return;
    if (kits.isNotEmpty) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Produto em uso'),
          content: Text(
            'Este produto está em: ${kits.join(', ')}. '
            'Excluir mesmo assim?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        ),
      );
      if (confirmar != true) return;
    }
    await controller.excluir(produto.id);
  }

  @override
  Widget build(BuildContext context) {
    final produtosAsync = ref.watch(produtosProvider);
    final faixas = ref.watch(faixasAbelinhaProvider).valueOrNull ?? const [];
    final v = ref.watch(configuracoesProvider).valueOrNull?.valorAbelinha ??
        Decimal.zero;
    final vendidos =
        ref.watch(vendidosPorProdutoProvider).valueOrNull ?? const {};
    final codigosRepetidos =
        ref.watch(codigosRepetidosProvider).valueOrNull ?? const {};

    final total = produtosAsync.valueOrNull?.length ?? 0;
    final categorias = <String>{
      for (final p in produtosAsync.valueOrNull ?? const <Produto>[])
        p.categoria,
    }.toList()
      ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Produtos',
          actions: [
            FilledButton.icon(
              onPressed: () => _novo(faixas, v),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Novo produto'),
            ),
          ],
        ),
        _Filtros(
          categorias: categorias,
          categoria: _categoria,
          aoBuscar: (t) => setState(() => _busca = t),
          aoFiltrar: (c) => setState(() => _categoria = c ?? ''),
        ),
        const SizedBox(height: Espacos.g16),
        EstadoLista<Produto>(
          estado: produtosAsync,
          mensagemVazia: 'Nenhum produto. Use “Novo produto” para '
              'cadastrar o primeiro.',
          aoTentarDeNovo: () => ref.invalidate(produtosProvider),
          acaoVazio: FilledButton.icon(
            onPressed: () => _novo(faixas, v),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('Novo produto'),
          ),
          comDados: (produtos) {
            final filtrados = _filtrar(produtos);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: Espacos.g12),
                  child: Text(
                    '${filtrados.length} de $total',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: context.cores.muted),
                  ),
                ),
                ResponsiveList<Produto>(
                  itens: filtrados,
                  colunas: _colunas(
                    faixas,
                    v,
                    vendidos,
                    codigosRepetidos,
                  ),
                  acoes: (p) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconAction(
                        icon: LucideIcons.pencil,
                        tooltip: 'Editar',
                        onPressed: () => _editar(p, faixas, v),
                      ),
                      ConfirmDeleteButton(onConfirm: () => _excluir(p)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  List<ColunaLista<Produto>> _colunas(
    List<FaixaAbelinha> faixas,
    Decimal v,
    Map<String, int> vendidos,
    Set<String> codigosRepetidos,
  ) {
    return [
      ColunaLista<Produto>(
        label: 'Produto',
        principal: true,
        builder: (p) => _CelulaProduto(
          produto: p,
          codigoRepetido: codigosRepetidos.contains(p.codigo),
        ),
      ),
      ColunaLista<Produto>(
        label: 'Custo un.',
        builder: (p) => _CelulaCusto(produto: p),
      ),
      ColunaLista<Produto>(
        label: 'Abelinhas',
        builder: (p) => _CelulaAbelinhas(
          produto: p,
          faixas: faixas,
          aoEditar: () => _editar(p, faixas, v),
        ),
      ),
      ColunaLista<Produto>(
        label: 'Estoque',
        builder: (p) => _CelulaEstoque(
          produto: p,
          vendidos: vendidos[p.id] ?? 0,
        ),
      ),
    ];
  }
}

/// Linha de busca e filtro por categoria.
class _Filtros extends StatelessWidget {
  const _Filtros({
    required this.categorias,
    required this.categoria,
    required this.aoBuscar,
    required this.aoFiltrar,
  });

  final List<String> categorias;
  final String categoria;
  final ValueChanged<String> aoBuscar;
  final ValueChanged<String?> aoFiltrar;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Espacos.g12,
      runSpacing: Espacos.g12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 320,
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(LucideIcons.search, size: 18),
              labelText: 'Buscar por código, nome, marca ou fornecedor',
            ),
            onChanged: aoBuscar,
          ),
        ),
        SizedBox(
          width: 220,
          child: DropdownButtonFormField<String>(
            initialValue: categoria.isEmpty ? null : categoria,
            decoration: const InputDecoration(labelText: 'Categoria'),
            items: [
              const DropdownMenuItem(value: '', child: Text('Todas')),
              for (final c in categorias)
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: aoFiltrar,
          ),
        ),
      ],
    );
  }
}

/// Célula principal: nome em destaque + código/marca/categoria e pills de
/// estado (inativo / código repetido).
class _CelulaProduto extends StatelessWidget {
  const _CelulaProduto({
    required this.produto,
    required this.codigoRepetido,
  });

  final Produto produto;
  final bool codigoRepetido;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(produto.nome, style: textos.titleMedium),
        const SizedBox(height: Espacos.base),
        Wrap(
          spacing: Espacos.g8,
          runSpacing: Espacos.base,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CodeChip(produto.codigo),
            if (produto.marca.isNotEmpty)
              Text(
                produto.marca,
                style: textos.bodySmall?.copyWith(color: cores.muted),
              ),
            Text(
              produto.categoria,
              style: textos.bodySmall?.copyWith(color: cores.muted),
            ),
            if (!produto.ativo) const Pill('inativo'),
            if (codigoRepetido)
              const Pill('código repetido', tom: TomPill.atencao),
          ],
        ),
      ],
    );
  }
}

/// Célula de estoque: quantidade com unidade + "N vendido(s)" abaixo.
class _CelulaEstoque extends StatelessWidget {
  const _CelulaEstoque({required this.produto, required this.vendidos});

  final Produto produto;
  final int vendidos;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${produto.estoque} ${produto.unidade}'),
        const SizedBox(height: Espacos.base),
        Text(
          '$vendidos vendido(s)',
          style: textos.bodySmall?.copyWith(color: cores.muted),
        ),
      ],
    );
  }
}

/// Célula de custo: valor + fornecedor abaixo.
class _CelulaCusto extends StatelessWidget {
  const _CelulaCusto({required this.produto});

  final Produto produto;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(Formatos.moedaDecimal(produto.custo)),
        if (produto.fornecedor.isNotEmpty) ...[
          const SizedBox(height: Espacos.base),
          Text(
            produto.fornecedor,
            style: textos.bodySmall?.copyWith(color: cores.muted),
          ),
        ],
      ],
    );
  }
}

/// Célula de abelinhas: quantidade + pill "pela regra"/"ajustado" e botão ✎.
class _CelulaAbelinhas extends StatelessWidget {
  const _CelulaAbelinhas({
    required this.produto,
    required this.faixas,
    required this.aoEditar,
  });

  final Produto produto;
  final List<FaixaAbelinha> faixas;
  final VoidCallback aoEditar;

  @override
  Widget build(BuildContext context) {
    if (faixas.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Abelinhas((produto.abelinhasManual ?? Decimal.zero).toDouble()),
          IconAction(
            icon: LucideIcons.pencil,
            tooltip: 'Editar abelinhas',
            onPressed: aoEditar,
          ),
        ],
      );
    }
    final regra = abelinhasRegra(produto.custo, faixas);
    final atual = abelinhasProduto(produto, faixas);
    final acima = acimaDaTabela(produto.custo, faixas);
    final manual = produto.abelinhasManual;

    final String texto;
    final TomPill tom;
    if (manual == null) {
      // Pela regra; amarela quando o custo está acima da última faixa.
      texto = acima ? 'ajustado' : 'pela regra';
      tom = acima ? TomPill.atencao : TomPill.neutro;
    } else if (manual < regra) {
      texto = 'ajustado';
      tom = TomPill.atencao;
    } else if (manual > regra) {
      texto = 'ajustado';
      tom = TomPill.bom;
    } else {
      texto = 'pela regra';
      tom = TomPill.neutro;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Abelinhas(atual.toDouble()),
            IconAction(
              icon: LucideIcons.pencil,
              tooltip: 'Editar abelinhas',
              onPressed: aoEditar,
            ),
          ],
        ),
        const SizedBox(height: Espacos.base),
        Pill(texto, tom: tom),
      ],
    );
  }
}
