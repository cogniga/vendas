import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/config/supabase_config.dart';
import 'package:sales/data/repositorios/erros_repositorio.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório de [Plataforma] e suas [FaixaTaxa].
class PlataformaRepository {
  /// Cria o repositório com o [SupabaseClient] injetado.
  PlataformaRepository(this._client);

  final SupabaseClient _client;

  /// Plataformas (ordem asc) com suas faixas de taxa (preço asc).
  Future<Map<Plataforma, List<FaixaTaxa>>> listarComFaixas(
    String empresaId,
  ) async {
    final linhasPlat = await _client
        .from('plataformas')
        .select()
        .eq('empresa_id', empresaId)
        .order('ordem');
    final linhasFaixas = await _client
        .from('faixas_taxa')
        .select()
        .eq('empresa_id', empresaId);
    final faixas = linhasFaixas.map(FaixaTaxa.fromJson).toList();
    final resultado = <Plataforma, List<FaixaTaxa>>{};
    for (final linha in linhasPlat) {
      final plataforma = Plataforma.fromJson(linha);
      final suas = faixas
          .where((f) => f.plataformaId == plataforma.id)
          .toList()
        ..sort(_compararFaixas);
      resultado[plataforma] = suas;
    }
    return resultado;
  }

  /// Cria uma plataforma e retorna a entidade persistida.
  Future<Plataforma> criar(String empresaId, String nome) async {
    final linha = await _client
        .from('plataformas')
        .insert({'empresa_id': empresaId, 'nome': nome})
        .select()
        .single();
    return Plataforma.fromJson(linha);
  }

  /// Renomeia a plataforma [id].
  Future<void> renomear(String id, String nome) async {
    await _client.from('plataformas').update({'nome': nome}).eq('id', id);
  }

  /// Muda a cor da plataforma [id].
  Future<void> mudarCor(String id, String cor) async {
    await _client.from('plataformas').update({'cor': cor}).eq('id', id);
  }

  /// Atualiza a aparência (cor e observação) da plataforma [id].
  Future<void> atualizarAparencia(String id, String cor, String obs) async {
    await _client
        .from('plataformas')
        .update({'cor': cor, 'obs': obs})
        .eq('id', id);
  }

  /// Exclui a plataforma [id].
  ///
  /// Bloqueia com [ErroRepositorio] se houver pedidos ou saques que a
  /// referenciam (as FKs são `on delete restrict`).
  Future<void> excluir(String id) async {
    final pedidos = await _client
        .from('pedidos')
        .count()
        .eq('plataforma_id', id);
    final saques = await _client
        .from('saques')
        .count()
        .eq('plataforma_id', id);
    if (pedidos > 0 || saques > 0) {
      throw const ErroRepositorio(
        'Não é possível excluir: a plataforma está em uso por '
        'pedidos ou saques.',
      );
    }
    await _client.from('plataformas').delete().eq('id', id);
  }

  /// Substitui todas as faixas de taxa da plataforma [plataformaId].
  Future<void> substituirFaixas(
    String plataformaId,
    String empresaId,
    List<FaixaTaxa> faixas,
  ) async {
    await _client
        .from('faixas_taxa')
        .delete()
        .eq('plataforma_id', plataformaId);
    if (faixas.isEmpty) return;
    await _client.from('faixas_taxa').insert([
      for (final f in faixas)
        {
          'empresa_id': empresaId,
          'plataforma_id': plataformaId,
          'preco_ate': f.precoAte?.toString(),
          'taxa_fixa': f.taxaFixa.toString(),
          'taxa_percentual': f.taxaPercentual.toString(),
        },
    ]);
  }

  // Faixa sem limite (precoAte null) fica por último.
  int _compararFaixas(FaixaTaxa a, FaixaTaxa b) {
    if (a.precoAte == null) return 1;
    if (b.precoAte == null) return -1;
    return a.precoAte!.compareTo(b.precoAte!);
  }
}

/// Provider do [PlataformaRepository].
final plataformaRepositoryProvider = Provider<PlataformaRepository>((ref) {
  return PlataformaRepository(ref.watch(supabaseClientProvider));
});
