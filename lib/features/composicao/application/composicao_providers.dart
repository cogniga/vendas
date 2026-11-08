import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/format/ordenacao.dart';
import 'package:sales/data/repositorios/compra_insumo_repository.dart';
import 'package:sales/data/repositorios/configuracoes_repository.dart';
import 'package:sales/data/repositorios/empresa_atual_provider.dart';
import 'package:sales/data/repositorios/faixa_abelinha_repository.dart';
import 'package:sales/data/repositorios/pedido_repository.dart';
import 'package:sales/data/repositorios/plataforma_repository.dart';
import 'package:sales/data/repositorios/produto_repository.dart';
import 'package:sales/data/repositorios/produto_venda_repository.dart';
import 'package:sales/domain/entidades/compra_insumo.dart';
import 'package:sales/domain/entidades/configuracoes.dart';
import 'package:sales/domain/entidades/enums.dart';
import 'package:sales/domain/entidades/faixa_abelinha.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/pedido.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:sales/domain/entidades/produto.dart';
import 'package:sales/domain/entidades/produto_venda.dart';

/// Produtos de venda (kits) da empresa ativa, com itens e preços montados.
final kitsProvider = FutureProvider.autoDispose<List<ProdutoVenda>>((
  ref,
) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return [];
  return ref.watch(produtoVendaRepositoryProvider).listar(empresa.id);
});

/// Plataformas da empresa ativa com suas faixas de taxa.
final plataformasComFaixasProvider =
    FutureProvider.autoDispose<Map<Plataforma, List<FaixaTaxa>>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return {};
  return ref.watch(plataformaRepositoryProvider).listarComFaixas(empresa.id);
});

/// Produtos (insumos de revenda) da empresa ativa, para montar os kits.
final produtosProvider = FutureProvider.autoDispose<List<Produto>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return [];
  return ref.watch(produtoRepositoryProvider).listar(empresa.id);
});

/// Regra de abelinhas (faixas custo → abelinhas) da empresa ativa.
final faixasAbelinhaProvider =
    FutureProvider.autoDispose<List<FaixaAbelinha>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return [];
  return ref.watch(faixaAbelinhaRepositoryProvider).listar(empresa.id);
});

/// Configurações da empresa ativa (valor da abelinha, padrões de custo).
final configuracoesProvider =
    FutureProvider.autoDispose<Configuracoes?>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return null;
  return ref.watch(configuracoesRepositoryProvider).obter(empresa.id);
});

/// Compras de insumos da empresa ativa (para escolher a embalagem do kit).
final comprasInsumoProvider =
    FutureProvider.autoDispose<List<CompraInsumo>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return [];
  return ref.watch(compraInsumoRepositoryProvider).listar(empresa.id);
});

/// Pedidos concluídos da empresa ativa, com itens, para contar unidades
/// vendidas por kit.
///
/// [PedidoRepository.listar] não traz os itens; como a contagem de vendidos
/// depende de `pedido.itens`, carregamos cada pedido concluído com
/// [PedidoRepository.obterComItens] (mesmo padrão de
/// `vendidosPorProdutoProvider` em Produtos).
final pedidosProvider = FutureProvider.autoDispose<List<Pedido>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return [];
  final repo = ref.watch(pedidoRepositoryProvider);
  final resumos = await repo.listar(empresa.id);
  final comItens = <Pedido>[];
  for (final resumo in resumos) {
    if (resumo.situacao != SituacaoPedido.concluido) continue;
    final pedido = await repo.obterComItens(resumo.id);
    if (pedido != null) comItens.add(pedido);
  }
  return comItens;
});

/// Kit completo (itens + preços por plataforma) para edição, por `id`.
final kitCompletoProvider =
    FutureProvider.autoDispose.family<ProdutoVenda?, String>((ref, id) async {
  return ref.watch(produtoVendaRepositoryProvider).obterCompleto(id);
});

/// Dados agregados que o editor de kit precisa, carregados juntos.
class DadosEdicaoKit {
  const DadosEdicaoKit({
    required this.plataformas,
    required this.produtosPorId,
    required this.faixasAbelinha,
    required this.configuracoes,
    required this.compras,
    required this.pedidos,
  });

  final Map<Plataforma, List<FaixaTaxa>> plataformas;
  final Map<String, Produto> produtosPorId;
  final List<FaixaAbelinha> faixasAbelinha;
  final Configuracoes? configuracoes;
  final List<CompraInsumo> compras;
  final List<Pedido> pedidos;

  /// Produtos ativos ordenados por nome (para o seletor de itens).
  List<Produto> get produtos =>
      ordenarAlfabetico(produtosPorId.values, (p) => p.nome);
}

/// Carrega tudo que o editor de kit precisa em um único provider.
final dadosEdicaoKitProvider =
    FutureProvider.autoDispose<DadosEdicaoKit>((ref) async {
  final plataformas = await ref.watch(plataformasComFaixasProvider.future);
  final produtos = await ref.watch(produtosProvider.future);
  final faixasAbelinha = await ref.watch(faixasAbelinhaProvider.future);
  final configuracoes = await ref.watch(configuracoesProvider.future);
  final compras = await ref.watch(comprasInsumoProvider.future);
  final pedidos = await ref.watch(pedidosProvider.future);
  return DadosEdicaoKit(
    plataformas: plataformas,
    produtosPorId: {for (final p in produtos) p.id: p},
    faixasAbelinha: faixasAbelinha,
    configuracoes: configuracoes,
    compras: compras,
    pedidos: pedidos,
  );
});
