import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/data/repositorios/empresa_repository.dart';
import 'package:sales/domain/entidades/empresa.dart';

/// Empresa ativa do usuário.
///
/// Decisão: hoje usamos a **primeira** empresa retornada por
/// [EmpresaRepository.listarMinhas] (ordem do banco). O tipo
/// `FutureProvider<Empresa?>` já está preparado para, no futuro, suportar a
/// escolha entre várias empresas sem quebrar os consumidores. Retorna `null`
/// quando o usuário ainda não tem nenhuma empresa (dispara o onboarding).
final empresaAtualProvider = FutureProvider<Empresa?>((ref) async {
  final repo = ref.watch(empresaRepositoryProvider);
  final lista = await repo.listarMinhas();
  return lista.isEmpty ? null : lista.first;
});
