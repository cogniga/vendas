import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/config/supabase_config.dart';
import 'package:sales/domain/entidades/saque.dart';
import 'package:sales/domain/entidades/saque_rateio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório de [Saque] e seu rateio entre destinos.
///
/// O rateio (snapshot percentual/valor por destino) é gravado junto com o
/// saque em [salvar].
class SaqueRepository {
  /// Cria o repositório com o [SupabaseClient] injetado.
  SaqueRepository(this._client);

  final SupabaseClient _client;

  /// Lista os saques da empresa [empresaId] (data desc) com rateio montado.
  Future<List<Saque>> listar(String empresaId) async {
    final linhas = await _client
        .from('saques')
        .select()
        .eq('empresa_id', empresaId)
        .order('data', ascending: false);
    final rateios = await _client
        .from('saques_rateio')
        .select()
        .eq('empresa_id', empresaId);
    final porSaque = <String, List<SaqueRateio>>{};
    for (final l in rateios) {
      final r = SaqueRateio.fromJson(l);
      (porSaque[r.saqueId] ??= []).add(r);
    }
    return linhas.map((l) {
      final saque = Saque.fromJson(l);
      return saque.copyWith(rateio: porSaque[saque.id] ?? const []);
    }).toList();
  }

  /// Grava o saque de forma coesa e retorna-o com o rateio.
  ///
  /// Grava a linha `saques` e substitui `saques_rateio` (delete + insert).
  Future<Saque> salvar(Saque saque) async {
    final linha = await _client
        .from('saques')
        .upsert(_paraLinha(saque))
        .select()
        .single();
    final id = linha['id'] as String;

    await _client.from('saques_rateio').delete().eq('saque_id', id);
    if (saque.rateio.isNotEmpty) {
      await _client.from('saques_rateio').insert([
        for (final r in saque.rateio)
          {
            'saque_id': id,
            'empresa_id': saque.empresaId,
            'destino_id': r.destinoId,
            'percentual': r.percentual.toString(),
            'valor': r.valor.toString(),
          },
      ]);
    }

    final rateios = await _client
        .from('saques_rateio')
        .select()
        .eq('saque_id', id);
    return Saque.fromJson(linha).copyWith(
      rateio: rateios.map(SaqueRateio.fromJson).toList(),
    );
  }

  /// Exclui o saque [id] (rateio cai por cascade).
  Future<void> excluir(String id) async {
    await _client.from('saques').delete().eq('id', id);
  }

  Map<String, dynamic> _paraLinha(Saque s) => {
        if (s.id.isNotEmpty) 'id': s.id,
        'empresa_id': s.empresaId,
        'data': s.data.toIso8601String(),
        'plataforma_id': s.plataformaId,
        'valor': s.valor.toString(),
        'obs': s.obs,
      };
}

/// Provider do [SaqueRepository].
final saqueRepositoryProvider = Provider<SaqueRepository>((ref) {
  return SaqueRepository(ref.watch(supabaseClientProvider));
});
