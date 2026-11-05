import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/data/repositorios/destino_repository.dart';
import 'package:sales/data/repositorios/empresa_atual_provider.dart';
import 'package:sales/data/repositorios/investimento_repository.dart';
import 'package:sales/domain/entidades/destino.dart';
import 'package:sales/domain/entidades/investimento.dart';

/// Investimentos da empresa ativa (ordem data desc).
final investimentosProvider =
    FutureProvider<List<Investimento>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return [];
  return ref.watch(investimentoRepositoryProvider).listar(empresa.id);
});

/// Destinos de rateio do caixa da empresa ativa (para "Pago com").
final destinosProvider = FutureProvider<List<Destino>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return [];
  return ref.watch(destinoRepositoryProvider).listar(empresa.id);
});
