import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/data/repositorios/empresa_repository.dart';
import 'package:sales/data/repositorios/empresa_selecionada.dart';
import 'package:sales/domain/entidades/empresa.dart';

/// Empresa ativa do sistema (modo sem login/sessão: RLS desligado).
///
/// Resolve nesta ordem:
/// 1. A empresa escolhida pelo usuário em Dados e configurações
///    ([empresaSelecionadaProvider]).
/// 2. Senão, a primeira de todas as empresas.
/// 3. Senão, `null` — a tela de configurações pede para escolher/criar uma.
final empresaAtualProvider = FutureProvider<Empresa?>((ref) async {
  final repo = ref.watch(empresaRepositoryProvider);
  final selecionada = ref.watch(empresaSelecionadaProvider);

  // 1. Empresa escolhida pelo usuário em Dados e configurações.
  if (selecionada != null && selecionada.isNotEmpty) {
    final empresa = await repo.obterPorId(selecionada);
    if (empresa != null) return empresa;
  }

  // 2. Nenhuma selecionada: usa a PRIMEIRA de todas as empresas.
  final todas = await repo.listarTodas();
  if (todas.isNotEmpty) return todas.first;

  // 3. Não há nenhuma empresa cadastrada.
  return null;
});
