import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/config/supabase_config.dart';
import 'package:sales/domain/entidades/destino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório de [Destino] de rateio do caixa.
class DestinoRepository {
  /// Cria o repositório com o [SupabaseClient] injetado.
  DestinoRepository(this._client);

  final SupabaseClient _client;

  /// Lista os destinos da empresa [empresaId] ordenados por `ordem`.
  Future<List<Destino>> listar(String empresaId) async {
    final linhas = await _client
        .from('destinos')
        .select()
        .eq('empresa_id', empresaId)
        .order('ordem');
    return linhas.map(Destino.fromJson).toList();
  }

  /// Obtém um destino por [id] ou `null` se não existir.
  Future<Destino?> obter(String id) async {
    final linha = await _client
        .from('destinos')
        .select()
        .eq('id', id)
        .maybeSingle();
    return linha == null ? null : Destino.fromJson(linha);
  }

  /// Cria um destino e retorna a entidade persistida.
  Future<Destino> criar(Destino destino) async {
    final linha = await _client
        .from('destinos')
        .insert(_paraLinha(destino))
        .select()
        .single();
    return Destino.fromJson(linha);
  }

  /// Atualiza um destino e retorna a entidade persistida.
  Future<Destino> atualizar(Destino destino) async {
    final linha = await _client
        .from('destinos')
        .update(_paraLinha(destino))
        .eq('id', destino.id)
        .eq('empresa_id', destino.empresaId)
        .select()
        .single();
    return Destino.fromJson(linha);
  }

  /// Exclui um destino por [id].
  Future<void> excluir(String id) async {
    await _client.from('destinos').delete().eq('id', id);
  }

  Map<String, dynamic> _paraLinha(Destino d) => {
        'empresa_id': d.empresaId,
        'nome': d.nome,
        'cor': d.cor,
        'percentual': d.percentual.toString(),
        'ordem': d.ordem,
      };
}

/// Provider do [DestinoRepository].
final destinoRepositoryProvider = Provider<DestinoRepository>((ref) {
  return DestinoRepository(ref.watch(supabaseClientProvider));
});
