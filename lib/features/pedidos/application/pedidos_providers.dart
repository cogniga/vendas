import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/data/repositorios/configuracoes_repository.dart';
import 'package:sales/data/repositorios/empresa_atual_provider.dart';
import 'package:sales/data/repositorios/faixa_abelinha_repository.dart';
import 'package:sales/data/repositorios/pedido_repository.dart';
import 'package:sales/data/repositorios/plataforma_repository.dart';
import 'package:sales/data/repositorios/produto_repository.dart';
import 'package:sales/data/repositorios/produto_venda_repository.dart';
import 'package:sales/domain/entidades/configuracoes.dart';
import 'package:sales/domain/entidades/faixa_abelinha.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/pedido.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:sales/domain/entidades/produto.dart';
import 'package:sales/domain/entidades/produto_venda.dart';

/// Lista de pedidos da empresa ativa (ordem data desc).
final pedidosProvider = FutureProvider<List<Pedido>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return [];
  return ref.watch(pedidoRepositoryProvider).listar(empresa.id);
});

/// Plataformas da empresa ativa com suas faixas de taxa.
final plataformasComFaixasProvider =
    FutureProvider<Map<Plataforma, List<FaixaTaxa>>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return {};
  return ref.watch(plataformaRepositoryProvider).listarComFaixas(empresa.id);
});

/// Produtos da empresa ativa (para montar itens de pedido).
final produtosProvider = FutureProvider<List<Produto>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return [];
  return ref.watch(produtoRepositoryProvider).listar(empresa.id);
});

/// Produtos de venda (kits) da empresa ativa, já com itens carregados.
final kitsProvider = FutureProvider<List<ProdutoVenda>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return [];
  return ref.watch(produtoVendaRepositoryProvider).listar(empresa.id);
});

/// Configurações da empresa ativa (valor da abelinha, padrões).
final configuracoesProvider = FutureProvider<Configuracoes?>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return null;
  return ref.watch(configuracoesRepositoryProvider).obter(empresa.id);
});

/// Regra de abelinhas (faixas) da empresa ativa.
final faixasAbelinhaProvider =
    FutureProvider<List<FaixaAbelinha>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return [];
  return ref.watch(faixaAbelinhaRepositoryProvider).listar(empresa.id);
});

/// Dados agregados que o editor de pedido precisa, carregados juntos.
class DadosEdicaoPedido {
  const DadosEdicaoPedido({
    required this.plataformas,
    required this.produtos,
    required this.kits,
    required this.configuracoes,
    required this.faixasAbelinha,
  });

  final Map<Plataforma, List<FaixaTaxa>> plataformas;
  final List<Produto> produtos;
  final List<ProdutoVenda> kits;
  final Configuracoes? configuracoes;
  final List<FaixaAbelinha> faixasAbelinha;
}

/// Carrega tudo que o editor de pedido precisa em um único provider.
final dadosEdicaoPedidoProvider =
    FutureProvider<DadosEdicaoPedido>((ref) async {
  final plataformas = await ref.watch(plataformasComFaixasProvider.future);
  final produtos = await ref.watch(produtosProvider.future);
  final kits = await ref.watch(kitsProvider.future);
  final configuracoes = await ref.watch(configuracoesProvider.future);
  final faixasAbelinha = await ref.watch(faixasAbelinhaProvider.future);
  return DadosEdicaoPedido(
    plataformas: plataformas,
    produtos: produtos,
    kits: kits,
    configuracoes: configuracoes,
    faixasAbelinha: faixasAbelinha,
  );
});
