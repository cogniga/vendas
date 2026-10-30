import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/config/supabase_config.dart';
import 'package:sales/domain/entidades/investimento.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório de [Investimento] (compra de mercadoria por distribuidor).
class InvestimentoRepository {
  /// Cria o repositório com o [SupabaseClient] injetado.
  InvestimentoRepository(this._client);

  final SupabaseClient _client;

  /// Lista os investimentos da empresa [empresaId] por `data` desc.
  Future<List<Investimento>> listar(String empresaId) async {
    final linhas = await _client
        .from('investimentos')
        .select()
        .eq('empresa_id', empresaId)
        .order('data', ascending: false);
    return linhas.map(Investimento.fromJson).toList();
  }

  /// Obtém um investimento por [id] ou `null` se não existir.
  Future<Investimento?> obter(String id) async {
    final linha = await _client
        .from('investimentos')
        .select()
        .eq('id', id)
        .maybeSingle();
    return linha == null ? null : Investimento.fromJson(linha);
  }

  /// Cria um investimento e retorna a entidade persistida.
  Future<Investimento> criar(Investimento investimento) async {
    final linha = await _client
        .from('investimentos')
        .insert(_paraLinha(investimento))
        .select()
        .single();
    return Investimento.fromJson(linha);
  }

  /// Atualiza um investimento e retorna a entidade persistida.
  Future<Investimento> atualizar(Investimento investimento) async {
    final linha = await _client
        .from('investimentos')
        .update(_paraLinha(investimento))
        .eq('id', investimento.id)
        .eq('empresa_id', investimento.empresaId)
        .select()
        .single();
    return Investimento.fromJson(linha);
  }

  /// Exclui um investimento por [id].
  Future<void> excluir(String id) async {
    await _client.from('investimentos').delete().eq('id', id);
  }

  Map<String, dynamic> _paraLinha(Investimento i) => {
        'empresa_id': i.empresaId,
        'data': i.data.toIso8601String(),
        'distribuidor': i.distribuidor,
        'valor': i.valor.toString(),
        'nota': i.nota,
        'destino_id': i.destinoId,
        'obs': i.obs,
      };
}

/// Provider do [InvestimentoRepository].
final investimentoRepositoryProvider =
    Provider<InvestimentoRepository>((ref) {
  return InvestimentoRepository(ref.watch(supabaseClientProvider));
});
