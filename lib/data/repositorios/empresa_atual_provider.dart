import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/config/supabase_config.dart';
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
  final client = ref.watch(supabaseClientProvider);
  // Sem sessão não há como consultar (RLS bloqueia): devolve null.
  if (client.auth.currentSession == null) return null;

  final repo = ref.watch(empresaRepositoryProvider);
  final lista = await repo.listarMinhas();
  if (lista.isNotEmpty) return lista.first;

  // Nenhuma empresa ainda: cria uma padrão automaticamente (acesso anônimo).
  // A RPC `criar_empresa` já semeia configurações, plataformas, faixas e
  // destinos. Depois relê para retornar a entidade completa.
  await repo.criarEmpresa('Minha empresa');
  final novas = await repo.listarMinhas();
  return novas.isEmpty ? null : novas.first;
});
