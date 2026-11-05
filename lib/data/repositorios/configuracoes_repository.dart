import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/config/supabase_config.dart';
import 'package:sales/domain/entidades/configuracoes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório das [Configuracoes] da empresa (1 linha por empresa).
class ConfiguracoesRepository {
  /// Cria o repositório com o [SupabaseClient] injetado.
  ConfiguracoesRepository(this._client);

  final SupabaseClient _client;

  /// Obtém as configurações da empresa [empresaId].
  ///
  /// Se a empresa ainda não tiver uma linha de configurações (ex.: empresa
  /// criada manualmente, sem passar pela RPC `criar_empresa`), cria uma com
  /// os valores padrão e a retorna.
  Future<Configuracoes> obter(String empresaId) async {
    final linha = await _client
        .from('configuracoes')
        .select()
        .eq('empresa_id', empresaId)
        .maybeSingle();
    if (linha != null) return Configuracoes.fromJson(linha);

    final criada = await _client
        .from('configuracoes')
        .insert({'empresa_id': empresaId})
        .select()
        .single();
    return Configuracoes.fromJson(criada);
  }

  /// Atualiza as configurações da empresa dona de [config].
  Future<void> atualizar(Configuracoes config) async {
    await _client
        .from('configuracoes')
        .update({
          'embalagem_padrao': config.embalagemPadrao.toString(),
          'impressao_padrao': config.impressaoPadrao.toString(),
          'valor_abelinha': config.valorAbelinha.toString(),
        })
        .eq('empresa_id', config.empresaId);
  }
}

/// Provider do [ConfiguracoesRepository].
final configuracoesRepositoryProvider =
    Provider<ConfiguracoesRepository>((ref) {
  return ConfiguracoesRepository(ref.watch(supabaseClientProvider));
});
