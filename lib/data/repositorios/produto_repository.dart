import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/config/supabase_config.dart';
import 'package:sales/core/format/ordenacao.dart';
import 'package:sales/data/repositorios/erros_repositorio.dart';
import 'package:sales/domain/entidades/produto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório de [Produto] — tabela `produto_online` (DECISÃO D1).
class ProdutoRepository {
  /// Cria o repositório com o [SupabaseClient] injetado.
  ProdutoRepository(this._client);

  final SupabaseClient _client;

  /// Lista os produtos da empresa [empresaId] em ordem alfabética pt-BR do
  /// nome (sem diferenciar maiúsculas/acentos; ver `ordenacao.dart`).
  Future<List<Produto>> listar(String empresaId) async {
    final linhas = await _client
        .from('produto_online')
        .select()
        .eq('empresa_id', empresaId);
    return ordenarAlfabetico(linhas.map(Produto.fromJson), (p) => p.nome);
  }

  /// Obtém um produto por [id] ou `null` se não existir.
  Future<Produto?> obter(String id) async {
    final linha = await _client
        .from('produto_online')
        .select()
        .eq('id', id)
        .maybeSingle();
    return linha == null ? null : Produto.fromJson(linha);
  }

  /// Cria um produto e retorna a entidade persistida (com `id` gerado).
  ///
  /// Lança [ErroRepositorio] quando o código já existe na empresa.
  Future<Produto> criar(Produto produto) async {
    try {
      final linha = await _client
          .from('produto_online')
          .insert(_paraLinha(produto))
          .select()
          .single();
      return Produto.fromJson(linha);
    } on PostgrestException catch (e) {
      throw ErroRepositorio.dePostgrest(
        e,
        mensagemUnique:
            'Já existe um produto com o código ${produto.codigo}',
      );
    }
  }

  /// Atualiza um produto existente e retorna a entidade persistida.
  ///
  /// Lança [ErroRepositorio] quando o código já existe na empresa.
  Future<Produto> atualizar(Produto produto) async {
    try {
      final linha = await _client
          .from('produto_online')
          .update(_paraLinha(produto))
          .eq('id', produto.id)
          .eq('empresa_id', produto.empresaId)
          .select()
          .single();
      return Produto.fromJson(linha);
    } on PostgrestException catch (e) {
      throw ErroRepositorio.dePostgrest(
        e,
        mensagemUnique:
            'Já existe um produto com o código ${produto.codigo}',
      );
    }
  }

  /// Exclui um produto por [id].
  Future<void> excluir(String id) async {
    await _client.from('produto_online').delete().eq('id', id);
  }

  /// Nomes dos kits (produtos de venda) que usam o produto [produtoId].
  ///
  /// Usado no aviso de exclusão (R3.9).
  Future<List<String>> kitsQueUsam(String produtoId) async {
    final linhas = await _client
        .from('produtos_venda_itens')
        .select('produtos_venda(nome)')
        .eq('produto_id', produtoId);
    return linhas
        .map((l) => l['produtos_venda'] as Map<String, dynamic>?)
        .where((pv) => pv != null)
        .map((pv) => pv!['nome'] as String)
        .toSet()
        .toList();
  }

  Map<String, dynamic> _paraLinha(Produto p) => {
        'empresa_id': p.empresaId,
        'codigo': p.codigo,
        'nome': p.nome,
        'marca': p.marca,
        'categoria': p.categoria,
        'fornecedor': p.fornecedor,
        'custo': p.custo.toString(),
        'unidade': p.unidade,
        'estoque': p.estoque,
        'ean': p.ean,
        'ativo': p.ativo,
        'obs': p.obs,
        'abelinhas_manual': p.abelinhasManual?.toString(),
      };
}

/// Provider do [ProdutoRepository].
final produtoRepositoryProvider = Provider<ProdutoRepository>((ref) {
  return ProdutoRepository(ref.watch(supabaseClientProvider));
});
