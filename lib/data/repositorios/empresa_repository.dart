import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/config/supabase_config.dart';
import 'package:sales/domain/entidades/empresa.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório da entidade [Empresa] (tenant).
///
/// As empresas do usuário são obtidas por `membros` (join com `empresas`),
/// respeitando a RLS. A criação usa a RPC `criar_empresa`, que já semeia
/// configurações, faixas, plataformas e destinos padrão.
class EmpresaRepository {
  /// Cria o repositório com o [SupabaseClient] injetado.
  EmpresaRepository(this._client);

  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  /// Cria uma empresa via RPC `criar_empresa` e retorna o `uuid` gerado.
  Future<String> criarEmpresa(String nome) async {
    final id = await _client.rpc<String>(
      'criar_empresa',
      params: {'p_nome': nome},
    );
    return id;
  }

  /// Lista as empresas das quais o usuário atual é membro.
  Future<List<Empresa>> listarMinhas() async {
    final linhas = await _client
        .from('membros')
        .select('empresas(*)')
        .eq('user_id', _uid);
    return linhas
        .map((linha) => linha['empresas'] as Map<String, dynamic>)
        .map(Empresa.fromJson)
        .toList();
  }

  /// Obtém uma empresa por [id] ou `null` se não existir/sem acesso.
  Future<Empresa?> obterPorId(String id) async {
    final linha = await _client
        .from('empresas')
        .select()
        .eq('id', id)
        .maybeSingle();
    return linha == null ? null : Empresa.fromJson(linha);
  }

  /// Lista TODAS as empresas (via RPC `listar_todas_empresas`), para o
  /// seletor de empresa em Dados e configurações.
  ///
  /// Com o RLS desligado, consulta a tabela diretamente (sem RPC).
  Future<List<Empresa>> listarTodas() async {
    final linhas = await _client
        .from('empresas')
        .select()
        .order('criado_em', ascending: true);
    return linhas.map(Empresa.fromJson).toList();
  }

  /// Vincula o usuário atual como membro de [empresaId] (via RPC
  /// `entrar_empresa`) e retorna o id. Idempotente.
  Future<String> entrarEmpresa(String empresaId) async {
    return _client.rpc<String>(
      'entrar_empresa',
      params: {'p_empresa': empresaId},
    );
  }
}

/// Provider do [EmpresaRepository].
final empresaRepositoryProvider = Provider<EmpresaRepository>((ref) {
  return EmpresaRepository(ref.watch(supabaseClientProvider));
});
