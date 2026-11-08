import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sales/core/format/formatos.dart';
import 'package:sales/core/theme/tokens.dart';
import 'package:sales/core/widgets/confirm_delete_button.dart';
import 'package:sales/core/widgets/icon_action.dart';
import 'package:sales/core/widgets/page_header.dart';
import 'package:sales/core/widgets/responsive_list.dart';
import 'package:sales/domain/calculos/abelinhas.dart';
import 'package:sales/domain/calculos/produto_venda.dart';
import 'package:sales/domain/entidades/faixa_abelinha.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:sales/domain/entidades/produto.dart';
import 'package:sales/domain/entidades/produto_venda.dart';
import 'package:sales/features/composicao/application/composicao_providers.dart';
import 'package:sales/features/composicao/application/kit_form_controller.dart';
import 'package:sales/features/composicao/presentation/kit_editor.dart';

/// Tela da Composição de custo (R4): produtos de venda (kits) com uma coluna
/// por plataforma mostrando o lucro por venda.
class ComposicaoPage extends ConsumerStatefulWidget {
  const ComposicaoPage({super.key});

  @override
  ConsumerState<ComposicaoPage> createState() => _ComposicaoPageState();
}

class _ComposicaoPageState extends ConsumerState<ComposicaoPage> {
  Future<void> _abrir(ProdutoVenda? kit) async {
    final salvou = await abrirKitEditor(context, kit: kit);
    if ((salvou ?? false) && mounted) ref.invalidate(kitsProvider);
  }

  Future<void> _duplicar(ProdutoVenda kit) async {
    final ok = await ref.read(kitFormControllerProvider.notifier)
        .duplicar(kit.id);
    if (!mounted) return;
    if (ok) {
      ref.invalidate(kitsProvider);
    } else {
      _toast('Não foi possível duplicar. Tente de novo.');
    }
  }

  Future<void> _excluir(ProdutoVenda kit) async {
    final ok =
        await ref.read(kitFormControllerProvider.notifier).excluir(kit.id);
    if (!mounted) return;
    if (ok) {
      ref.invalidate(kitsProvider);
    } else {
      _toast('Não foi possível excluir. Tente de novo.');
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final kitsAsync = ref.watch(kitsProvider);
    final plataformasAsync = ref.watch(plataformasComFaixasProvider);
    final produtosAsync = ref.watch(produtosProvider);
    final faixasAsync = ref.watch(faixasAbelinhaProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: 'Composição de custo',
          subtitle: 'Cadastre o produto de venda uma vez. O custo é o mesmo '
              'em todo lugar e o sistema calcula taxa, líquido e lucro em '
              'cada plataforma. Na hora do pedido, basta escolher a '
              'plataforma.',
          actions: [
            FilledButton.icon(
              onPressed: () => _abrir(null),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Novo produto de venda'),
            ),
          ],
        ),
        plataformasAsync.when(
          loading: _Carregando.new,
          error: (e, _) => _Erro(
            onTentar: () => ref.invalidate(plataformasComFaixasProvider),
          ),
          data: (plataformas) => produtosAsync.when(
            loading: _Carregando.new,
            error: (e, _) =>
                _Erro(onTentar: () => ref.invalidate(produtosProvider)),
            data: (produtos) => faixasAsync.when(
              loading: _Carregando.new,
              error: (e, _) => _Erro(
                onTentar: () => ref.invalidate(faixasAbelinhaProvider),
              ),
              data: (faixasAbelinha) => kitsAsync.when(
                loading: _Carregando.new,
                error: (e, _) =>
                    _Erro(onTentar: () => ref.invalidate(kitsProvider)),
                data: (kits) => _Conteudo(
                  kits: kits,
                  plataformas: plataformas,
                  produtosPorId: {for (final p in produtos) p.id: p},
                  faixasAbelinha: faixasAbelinha,
                  onAbrir: _abrir,
                  onDuplicar: _duplicar,
                  onExcluir: _excluir,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({
    required this.kits,
    required this.plataformas,
    required this.produtosPorId,
    required this.faixasAbelinha,
    required this.onAbrir,
    required this.onDuplicar,
    required this.onExcluir,
  });

  final List<ProdutoVenda> kits;
  final Map<Plataforma, List<FaixaTaxa>> plataformas;
  final Map<String, Produto> produtosPorId;
  final List<FaixaAbelinha> faixasAbelinha;
  final void Function(ProdutoVenda) onAbrir;
  final void Function(ProdutoVenda) onDuplicar;
  final void Function(ProdutoVenda) onExcluir;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;

    // Painel único (protótipo `section.panel`): surface, borda 1px line,
    // radius 14, overflow hidden. Dentro, a tabela encostada ao topo e a hint
    // num rodapé com `border-top`, sem card interno nem margem solta.
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
          if (kits.isEmpty)
            const _Vazio()
          else ...[
            ResponsiveList<ProdutoVenda>(
              itens: kits,
              semMoldura: true,
              limiarCartao: 560,
              acoes: (k) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconAction(
                    icon: LucideIcons.eye,
                    tooltip: 'Abrir produto de venda',
                    onPressed: () => onAbrir(k),
                  ),
                  const SizedBox(width: Espacos.g8 - 2),
                  IconAction(
                    icon: LucideIcons.copy,
                    tooltip: 'Duplicar',
                    onPressed: () => onDuplicar(k),
                  ),
                  const SizedBox(width: Espacos.g8 - 2),
                  ConfirmDeleteButton(
                    tooltip: 'Excluir produto de venda',
                    onConfirm: () => onExcluir(k),
                  ),
                ],
              ),
              colunas: [
                ColunaLista<ProdutoVenda>(
                  label: 'Produto de venda',
                  principal: true,
                  builder: (k) => _CelulaKit(
                    kit: k,
                    produtosPorId: produtosPorId,
                  ),
                ),
                ColunaLista<ProdutoVenda>(
                  label: 'Investimento',
                  alinhamento: Alignment.centerRight,
                  builder: (k) => _CelulaInvestimento(
                    kit: k,
                    produtosPorId: produtosPorId,
                    faixasAbelinha: faixasAbelinha,
                  ),
                ),
                for (final e in plataformas.entries)
                  ColunaLista<ProdutoVenda>(
                    label: e.key.nome,
                    alinhamento: Alignment.centerRight,
                    cabecalho: _CabecalhoPlataforma(plataforma: e.key),
                    builder: (k) => _CelulaPlataforma(
                      kit: k,
                      plataforma: e.key,
                      faixas: e.value,
                      produtosPorId: produtosPorId,
                      faixasAbelinha: faixasAbelinha,
                    ),
                  ),
              ],
            ),
            // Rodapé do painel (protótipo `.toolbar` com `border-top`):
            // faixa encostada à tabela, padding 14x20, hint 12px muted.
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: cores.line)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Espacos.g20,
                  vertical: 14,
                ),
                child: Text(
                  'Em cada plataforma: lucro por venda, e abaixo o valor que '
                  'o cliente paga e a margem.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: cores.muted),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Cabeçalho de uma coluna de plataforma: bolinha com a cor + nome (como o
/// protótipo `<i class="dot">` + nome no `th`).
class _CabecalhoPlataforma extends StatelessWidget {
  const _CabecalhoPlataforma({required this.plataforma});

  final Plataforma plataforma;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final cor = _parseHex(plataforma.cor) ?? context.cores.accent;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            plataforma.nome,
            style: textos.labelLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  static Color? _parseHex(String hex) {
    var limpo = hex.trim().replaceAll('#', '').toUpperCase();
    if (limpo.length == 6) limpo = 'FF$limpo';
    if (limpo.length != 8) return null;
    final valor = int.tryParse(limpo, radix: 16);
    return valor == null ? null : Color(valor);
  }
}

class _CelulaKit extends StatelessWidget {
  const _CelulaKit({required this.kit, required this.produtosPorId});

  final ProdutoVenda kit;
  final Map<String, Produto> produtosPorId;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final composicao = kit.itens.map((i) {
      final codigo = produtosPorId[i.produtoId]?.codigo ?? '?';
      return '${i.quantidade}× $codigo';
    }).join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          kit.nome,
          style: textos.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (composicao.isNotEmpty) ...[
          const SizedBox(height: Espacos.base),
          Text(composicao, style: textos.bodySmall),
        ],
      ],
    );
  }
}

class _CelulaInvestimento extends StatelessWidget {
  const _CelulaInvestimento({
    required this.kit,
    required this.produtosPorId,
    required this.faixasAbelinha,
  });

  final ProdutoVenda kit;
  final Map<String, Produto> produtosPorId;
  final List<FaixaAbelinha> faixasAbelinha;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    var compra = Decimal.zero;
    var abelinhas = Decimal.zero;
    var nItens = 0;
    for (final item in kit.itens) {
      nItens += item.quantidade;
      final produto = produtosPorId[item.produtoId];
      if (produto == null) continue;
      final qtd = Decimal.fromInt(item.quantidade);
      compra += produto.custo * qtd;
      abelinhas += abelinhasProduto(produto, faixasAbelinha) * qtd;
    }
    final investimento =
        compra + kit.embalagem + kit.impressao + kit.outros;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(Formatos.moedaDecimal(investimento)),
        const SizedBox(height: Espacos.base),
        Text(
          '$nItens ${nItens == 1 ? 'item' : 'itens'} · '
          '${Formatos.abelinhas(abelinhas.toDouble())}',
          style: textos.bodySmall,
        ),
      ],
    );
  }
}

class _CelulaPlataforma extends StatelessWidget {
  const _CelulaPlataforma({
    required this.kit,
    required this.plataforma,
    required this.faixas,
    required this.produtosPorId,
    required this.faixasAbelinha,
  });

  final ProdutoVenda kit;
  final Plataforma plataforma;
  final List<FaixaTaxa> faixas;
  final Map<String, Produto> produtosPorId;
  final List<FaixaAbelinha> faixasAbelinha;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final r = calcularKit(
      kit,
      produtosPorId,
      plataforma,
      faixas,
      faixasAbelinha,
    );
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
        const SizedBox(height: Espacos.base),
        Text(
          '${Formatos.moedaDecimal(r.clientePaga)} · '
          '${Formatos.percentualFracao(r.margem.toDouble())}',
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
          const Text('Não foi possível carregar a composição.'),
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

class _Vazio extends StatelessWidget {
  const _Vazio();

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
          'Nenhum produto de venda ainda. Use "Novo produto de venda" '
          'para criar o primeiro.',
          textAlign: TextAlign.center,
          style: TextStyle(color: cores.muted),
        ),
      ),
    );
  }
}
