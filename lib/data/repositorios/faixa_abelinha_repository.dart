import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/config/supabase_config.dart';
import 'package:sales/domain/entidades/faixa_abelinha.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório das [FaixaAbelinha] (faixas custo → abelinhas).
class FaixaAbelinhaRepository {
  /// Cria o repositório com o [SupabaseClient] injetado.
  FaixaAbelinhaRepository(this._client);

  final SupabaseClient _client;

  /// Lista as faixas da empresa [empresaId] ordenadas por `custo_ate` asc.
  Future<List<FaixaAbelinha>> listar(String empresaId) async {
    final linhas = await _client
        .from('faixas_abelinha')
        .select()
        .eq('empresa_id', empresaId)
        .order('custo_ate');
    return linhas.map(FaixaAbelinha.fromJson).toList();
  }

  /// Substitui todas as faixas da empresa pelo conjunto [faixas].
  ///
  /// Apaga as faixas atuais da empresa e insere as novas em lote.
  Future<void> substituir(
    String empresaId,
    List<FaixaAbelinha> faixas,
  ) async {
    await _client
        .from('faixas_abelinha')
        .delete()
        .eq('empresa_id', empresaId);
    if (faixas.isEmpty) return;
    await _client.from('faixas_abelinha').insert([
      for (final f in faixas)
        {
          'empresa_id': empresaId,
          'custo_ate': f.custoAte.toString(),
          'abelinhas': f.abelinhas.toString(),
        },
    ]);
  }
}

/// Provider do [FaixaAbelinhaRepository].
final faixaAbelinhaRepositoryProvider =
    Provider<FaixaAbelinhaRepository>((ref) {
  return FaixaAbelinhaRepository(ref.watch(supabaseClientProvider));
});
