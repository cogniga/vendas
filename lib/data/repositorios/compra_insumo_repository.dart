import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/config/supabase_config.dart';
import 'package:sales/domain/entidades/compra_insumo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório de [CompraInsumo] (caixas, etiquetas, papel…).
class CompraInsumoRepository {
  /// Cria o repositório com o [SupabaseClient] injetado.
  CompraInsumoRepository(this._client);

  final SupabaseClient _client;

  /// Lista as compras da empresa [empresaId] ordenadas por `data` desc.
  Future<List<CompraInsumo>> listar(String empresaId) async {
    final linhas = await _client
        .from('compras_insumo')
        .select()
        .eq('empresa_id', empresaId)
        .order('data', ascending: false);
    return linhas.map(CompraInsumo.fromJson).toList();
  }

  /// Obtém uma compra por [id] ou `null` se não existir.
  Future<CompraInsumo?> obter(String id) async {
    final linha = await _client
        .from('compras_insumo')
        .select()
        .eq('id', id)
        .maybeSingle();
    return linha == null ? null : CompraInsumo.fromJson(linha);
  }

  /// Cria uma compra e retorna a entidade persistida.
  Future<CompraInsumo> criar(CompraInsumo compra) async {
    final linha = await _client
        .from('compras_insumo')
        .insert(_paraLinha(compra))
        .select()
        .single();
    return CompraInsumo.fromJson(linha);
  }

  /// Atualiza uma compra e retorna a entidade persistida.
  Future<CompraInsumo> atualizar(CompraInsumo compra) async {
    final linha = await _client
        .from('compras_insumo')
        .update(_paraLinha(compra))
        .eq('id', compra.id)
        .eq('empresa_id', compra.empresaId)
        .select()
        .single();
    return CompraInsumo.fromJson(linha);
  }

  /// Exclui uma compra por [id].
  Future<void> excluir(String id) async {
    await _client.from('compras_insumo').delete().eq('id', id);
  }

  Map<String, dynamic> _paraLinha(CompraInsumo c) => {
        'empresa_id': c.empresaId,
        'data': c.data.toIso8601String(),
        'tipo': c.tipo,
        'produto': c.produto,
        'descricao': c.descricao,
        'valor_total': c.valorTotal.toString(),
        'pacotes': c.pacotes,
        'itens': c.itens,
        'destino_id': c.destinoId,
      };
}

/// Provider do [CompraInsumoRepository].
final compraInsumoRepositoryProvider =
    Provider<CompraInsumoRepository>((ref) {
  return CompraInsumoRepository(ref.watch(supabaseClientProvider));
});
