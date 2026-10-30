import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/config/supabase_config.dart';
import 'package:sales/domain/entidades/retirada.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório de [Retirada] (saída de um destino do caixa).
class RetiradaRepository {
  /// Cria o repositório com o [SupabaseClient] injetado.
  RetiradaRepository(this._client);

  final SupabaseClient _client;

  /// Lista as retiradas da empresa [empresaId] ordenadas por `data` desc.
  Future<List<Retirada>> listar(String empresaId) async {
    final linhas = await _client
        .from('retiradas')
        .select()
        .eq('empresa_id', empresaId)
        .order('data', ascending: false);
    return linhas.map(Retirada.fromJson).toList();
  }

  /// Obtém uma retirada por [id] ou `null` se não existir.
  Future<Retirada?> obter(String id) async {
    final linha = await _client
        .from('retiradas')
        .select()
        .eq('id', id)
        .maybeSingle();
    return linha == null ? null : Retirada.fromJson(linha);
  }

  /// Cria uma retirada e retorna a entidade persistida.
  Future<Retirada> criar(Retirada retirada) async {
    final linha = await _client
        .from('retiradas')
        .insert(_paraLinha(retirada))
        .select()
        .single();
    return Retirada.fromJson(linha);
  }

  /// Atualiza uma retirada e retorna a entidade persistida.
  Future<Retirada> atualizar(Retirada retirada) async {
    final linha = await _client
        .from('retiradas')
        .update(_paraLinha(retirada))
        .eq('id', retirada.id)
        .eq('empresa_id', retirada.empresaId)
        .select()
        .single();
    return Retirada.fromJson(linha);
  }

  /// Exclui uma retirada por [id].
  Future<void> excluir(String id) async {
    await _client.from('retiradas').delete().eq('id', id);
  }

  Map<String, dynamic> _paraLinha(Retirada r) => {
        'empresa_id': r.empresaId,
        'data': r.data.toIso8601String(),
        'destino_id': r.destinoId,
        'valor': r.valor.toString(),
        'descricao': r.descricao,
      };
}

/// Provider do [RetiradaRepository].
final retiradaRepositoryProvider = Provider<RetiradaRepository>((ref) {
  return RetiradaRepository(ref.watch(supabaseClientProvider));
});
