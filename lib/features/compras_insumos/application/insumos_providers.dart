import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/data/repositorios/compra_insumo_repository.dart';
import 'package:sales/data/repositorios/destino_repository.dart';
import 'package:sales/data/repositorios/empresa_atual_provider.dart';
import 'package:sales/domain/entidades/compra_insumo.dart';
import 'package:sales/domain/entidades/destino.dart';

/// Compras de insumos da empresa ativa (ordem data desc).
final insumosProvider = FutureProvider<List<CompraInsumo>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return const [];
  return ref.watch(compraInsumoRepositoryProvider).listar(empresa.id);
});

/// Destinos de rateio do caixa da empresa ativa (ordem `ordem`).
final destinosProvider = FutureProvider<List<Destino>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return const [];
  return ref.watch(destinoRepositoryProvider).listar(empresa.id);
});
