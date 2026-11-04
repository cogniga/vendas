import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/data/repositorios/configuracoes_repository.dart';
import 'package:sales/data/repositorios/empresa_atual_provider.dart';
import 'package:sales/data/repositorios/faixa_abelinha_repository.dart';
import 'package:sales/data/repositorios/pedido_repository.dart';
import 'package:sales/data/repositorios/produto_repository.dart';
import 'package:sales/data/repositorios/produto_venda_repository.dart';
import 'package:sales/domain/entidades/configuracoes.dart';
import 'package:sales/domain/entidades/enums.dart';
import 'package:sales/domain/entidades/faixa_abelinha.dart';
import 'package:sales/domain/entidades/produto.dart';
import 'package:sales/domain/entidades/produto_venda_item.dart';

/// Produtos da empresa ativa (`produto_online`).
///
/// Lê [empresaAtualProvider]; retorna lista vazia quando ainda não há empresa.
final produtosProvider =
    FutureProvider.autoDispose<List<Produto>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return const [];
  return ref.watch(produtoRepositoryProvider).listar(empresa.id);
});

/// Faixas da regra de abelinhas da empresa ativa (ordenadas por custo).
final faixasAbelinhaProvider =
    FutureProvider.autoDispose<List<FaixaAbelinha>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return const [];
  return ref.watch(faixaAbelinhaRepositoryProvider).listar(empresa.id);
});

/// Configurações da empresa ativa (traz `valorAbelinha`).
///
/// Retorna `null` enquanto não há empresa.
final configuracoesProvider =
    FutureProvider.autoDispose<Configuracoes?>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return null;
  return ref.watch(configuracoesRepositoryProvider).obter(empresa.id);
});

/// Quantidade vendida por produto (`produtoId` -> unidades), somando só
/// pedidos [SituacaoPedido.concluido].
///
/// Para cada item avulso soma a quantidade; para itens de kit soma
/// `quantidade do item do kit × quantidade do kit no pedido`. Retorna mapa
/// vazio quando ainda não há empresa.
final vendidosPorProdutoProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return const {};

  final pedidoRepo = ref.watch(pedidoRepositoryProvider);
  final pedidos = await pedidoRepo.listar(empresa.id);

  final kits = await ref.watch(produtoVendaRepositoryProvider)
      .listar(empresa.id);
  final itensPorKit = <String, List<ProdutoVendaItem>>{
    for (final k in kits) k.id: k.itens,
  };

  final vendidos = <String, int>{};
  for (final resumo in pedidos) {
    if (resumo.situacao != SituacaoPedido.concluido) continue;
    final pedido = await pedidoRepo.obterComItens(resumo.id);
    if (pedido == null) continue;
    for (final item in pedido.itens) {
      switch (item.tipo) {
        case TipoPedidoItem.produto:
          final id = item.produtoId;
          if (id != null) {
            vendidos[id] = (vendidos[id] ?? 0) + item.quantidade;
          }
        case TipoPedidoItem.produtoVenda:
          final kitItens = itensPorKit[item.produtoVendaId] ?? const [];
          for (final ki in kitItens) {
            vendidos[ki.produtoId] = (vendidos[ki.produtoId] ?? 0) +
                ki.quantidade * item.quantidade;
          }
      }
    }
  }
  return vendidos;
});

/// Códigos de produto que aparecem em mais de um produto da empresa ativa.
///
/// Usado para sinalizar "código repetido" na lista. Vazio quando não há
/// empresa.
final codigosRepetidosProvider =
    FutureProvider.autoDispose<Set<String>>((ref) async {
  final produtos = await ref.watch(produtosProvider.future);
  final contagem = <String, int>{};
  for (final p in produtos) {
    contagem[p.codigo] = (contagem[p.codigo] ?? 0) + 1;
  }
  return {
    for (final e in contagem.entries)
      if (e.value > 1) e.key,
  };
});
