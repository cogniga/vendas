import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/data/repositorios/compra_insumo_repository.dart';
import 'package:sales/data/repositorios/destino_repository.dart';
import 'package:sales/data/repositorios/empresa_atual_provider.dart';
import 'package:sales/data/repositorios/investimento_repository.dart';
import 'package:sales/data/repositorios/retirada_repository.dart';
import 'package:sales/data/repositorios/saque_repository.dart';
import 'package:sales/domain/entidades/compra_insumo.dart';
import 'package:sales/domain/entidades/destino.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/investimento.dart';
import 'package:sales/domain/entidades/pedido.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:sales/domain/entidades/retirada.dart';
import 'package:sales/domain/entidades/saque.dart';
import 'package:sales/features/pedidos/application/pedidos_providers.dart';

/// Destinos de rateio do caixa da empresa ativa (ordem por `ordem`).
final destinosCaixaProvider = FutureProvider<List<Destino>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return [];
  return ref.watch(destinoRepositoryProvider).listar(empresa.id);
});

/// Saques da empresa ativa, já com o rateio montado (ordem data desc).
final saquesProvider = FutureProvider<List<Saque>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return [];
  return ref.watch(saqueRepositoryProvider).listar(empresa.id);
});

/// Retiradas do caixa da empresa ativa (ordem data desc).
final retiradasProvider = FutureProvider<List<Retirada>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return [];
  return ref.watch(retiradaRepositoryProvider).listar(empresa.id);
});

/// Investimentos da empresa ativa (ordem data desc).
final investimentosCaixaProvider =
    FutureProvider<List<Investimento>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return [];
  return ref.watch(investimentoRepositoryProvider).listar(empresa.id);
});

/// Compras de insumo da empresa ativa (ordem data desc).
final insumosCaixaProvider = FutureProvider<List<CompraInsumo>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return [];
  return ref.watch(compraInsumoRepositoryProvider).listar(empresa.id);
});

/// Dados agregados que a tela de caixa consome, carregados juntos.
class DadosCaixa {
  const DadosCaixa({
    required this.destinos,
    required this.saques,
    required this.investimentos,
    required this.comprasInsumo,
    required this.retiradas,
    required this.pedidos,
    required this.plataformas,
  });

  final List<Destino> destinos;
  final List<Saque> saques;
  final List<Investimento> investimentos;
  final List<CompraInsumo> comprasInsumo;
  final List<Retirada> retiradas;
  final List<Pedido> pedidos;
  final Map<Plataforma, List<FaixaTaxa>> plataformas;
}

/// Carrega tudo que a tela de caixa precisa em um único provider.
final dadosCaixaProvider = FutureProvider<DadosCaixa>((ref) async {
  final destinos = await ref.watch(destinosCaixaProvider.future);
  final saques = await ref.watch(saquesProvider.future);
  final investimentos = await ref.watch(investimentosCaixaProvider.future);
  final comprasInsumo = await ref.watch(insumosCaixaProvider.future);
  final retiradas = await ref.watch(retiradasProvider.future);
  final pedidos = await ref.watch(pedidosProvider.future);
  final plataformas = await ref.watch(plataformasComFaixasProvider.future);
  return DadosCaixa(
    destinos: destinos,
    saques: saques,
    investimentos: investimentos,
    comprasInsumo: comprasInsumo,
    retiradas: retiradas,
    pedidos: pedidos,
    plataformas: plataformas,
  );
});
