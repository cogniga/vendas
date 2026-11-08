import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/config/supabase_config.dart';
import 'package:sales/core/format/ordenacao.dart';
import 'package:sales/domain/entidades/preco_plataforma.dart';
import 'package:sales/domain/entidades/produto_venda.dart';
import 'package:sales/domain/entidades/produto_venda_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório de [ProdutoVenda] (kit), seus itens e preços por plataforma.
///
/// Mantém o agregado coeso: a linha de `produtos_venda`, os itens em
/// `produtos_venda_itens` e os preços em `produtos_venda_precos` são gravados
/// juntos em [salvar].
class ProdutoVendaRepository {
  /// Cria o repositório com o [SupabaseClient] injetado.
  ProdutoVendaRepository(this._client);

  final SupabaseClient _client;

  /// Lista os kits da empresa [empresaId] com itens e preços montados.
  Future<List<ProdutoVenda>> listar(String empresaId) async {
    final linhas = await _client
        .from('produtos_venda')
        .select()
        .eq('empresa_id', empresaId)
        .order('nome');
    final itens = await _client
        .from('produtos_venda_itens')
        .select()
        .eq('empresa_id', empresaId);
    final precos = await _client
        .from('produtos_venda_precos')
        .select()
        .eq('empresa_id', empresaId);
    final porItens = <String, List<ProdutoVendaItem>>{};
    for (final l in itens) {
      final item = ProdutoVendaItem.fromJson(l);
      (porItens[item.produtoVendaId] ??= []).add(item);
    }
    final porPrecos = <String, Map<String, PrecoPlataforma>>{};
    for (final l in precos) {
      final preco = PrecoPlataforma.fromJson(l);
      (porPrecos[preco.produtoVendaId] ??= {})[preco.plataformaId] = preco;
    }
    final kits = linhas.map((l) {
      final pv = ProdutoVenda.fromJson(l);
      return pv.copyWith(
        itens: porItens[pv.id] ?? const [],
        precosPorPlataforma: porPrecos[pv.id] ?? const {},
      );
    });
    // Ordem alfabética pt-BR (o order by do banco diferencia maiúsculas).
    return ordenarAlfabetico(kits, (k) => k.nome);
  }

  /// Obtém o kit [id] completo (itens + preços por plataforma).
  Future<ProdutoVenda?> obterCompleto(String id) async {
    final linha = await _client
        .from('produtos_venda')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (linha == null) return null;
    final itens = await _client
        .from('produtos_venda_itens')
        .select()
        .eq('produto_venda_id', id);
    final precos = await _client
        .from('produtos_venda_precos')
        .select()
        .eq('produto_venda_id', id);
    final precosMap = <String, PrecoPlataforma>{
      for (final p in precos.map(PrecoPlataforma.fromJson))
        p.plataformaId: p,
    };
    return ProdutoVenda.fromJson(linha).copyWith(
      itens: itens.map(ProdutoVendaItem.fromJson).toList(),
      precosPorPlataforma: precosMap,
    );
  }

  /// Grava o kit de forma coesa e retorna-o completo.
  ///
  /// Grava a linha `produtos_venda`, substitui os itens (delete + insert) e
  /// faz upsert dos preços (PK `produto_venda_id,plataforma_id`).
  Future<ProdutoVenda> salvar(ProdutoVenda kit) async {
    final linha = await _client
        .from('produtos_venda')
        .upsert(_paraLinha(kit))
        .select()
        .single();
    final id = linha['id'] as String;

    await _client
        .from('produtos_venda_itens')
        .delete()
        .eq('produto_venda_id', id);
    if (kit.itens.isNotEmpty) {
      await _client.from('produtos_venda_itens').insert([
        for (final i in kit.itens)
          {
            'empresa_id': kit.empresaId,
            'produto_venda_id': id,
            'produto_id': i.produtoId,
            'quantidade': i.quantidade,
          },
      ]);
    }

    if (kit.precosPorPlataforma.isNotEmpty) {
      await _client.from('produtos_venda_precos').upsert([
        for (final p in kit.precosPorPlataforma.values)
          {
            'empresa_id': kit.empresaId,
            'produto_venda_id': id,
            'plataforma_id': p.plataformaId,
            'preco': p.preco?.toString(),
            'desconto': p.desconto?.toString(),
            'cupom': p.cupom?.toString(),
            'vendidos_iniciais': p.vendidosIniciais,
          },
      ]);
    }

    return (await obterCompleto(id))!;
  }

  /// Duplica o kit [id] como `<nome> (cópia)` zerando `vendidos_iniciais`.
  Future<ProdutoVenda> duplicar(String id) async {
    final original = await obterCompleto(id);
    if (original == null) {
      throw StateError('Produto de venda não encontrado: $id');
    }
    final copia = original.copyWith(
      id: '',
      nome: '${original.nome} (cópia)',
      itens: [for (final i in original.itens) i.copyWith(id: '')],
      precosPorPlataforma: {
        for (final e in original.precosPorPlataforma.entries)
          e.key: e.value.copyWith(vendidosIniciais: 0),
      },
    );
    return salvar(copia);
  }

  /// Exclui o kit [id] (itens e preços caem por cascade).
  Future<void> excluir(String id) async {
    await _client.from('produtos_venda').delete().eq('id', id);
  }

  Map<String, dynamic> _paraLinha(ProdutoVenda k) => {
        if (k.id.isNotEmpty) 'id': k.id,
        'empresa_id': k.empresaId,
        'nome': k.nome,
        'embalagem': k.embalagem.toString(),
        'compra_insumo_id': k.compraInsumoId,
        'impressao': k.impressao.toString(),
        'outros': k.outros.toString(),
        'preco': k.preco.toString(),
        'desconto': k.desconto.toString(),
        'cupom': k.cupom.toString(),
        'preco_concorrente': k.precoConcorrente?.toString(),
        'meta_lucro': k.metaLucro.toString(),
        'fatia_roas': k.fatiaRoas.toString(),
        'margem_alvo': k.margemAlvo.toString(),
      };
}

/// Provider do [ProdutoVendaRepository].
final produtoVendaRepositoryProvider =
    Provider<ProdutoVendaRepository>((ref) {
  return ProdutoVendaRepository(ref.watch(supabaseClientProvider));
});
