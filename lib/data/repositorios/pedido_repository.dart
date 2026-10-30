import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/config/supabase_config.dart';
import 'package:sales/domain/entidades/enums.dart';
import 'package:sales/domain/entidades/pedido.dart';
import 'package:sales/domain/entidades/pedido_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório de [Pedido] e seus itens.
///
/// Os snapshots `custo_unitario`/`abelinhas_unitarias` de cada [PedidoItem]
/// são gravados como vêm — o cálculo é responsabilidade do chamador.
class PedidoRepository {
  /// Cria o repositório com o [SupabaseClient] injetado.
  PedidoRepository(this._client);

  final SupabaseClient _client;

  /// Lista os pedidos da empresa [empresaId] ordenados por `data` desc.
  Future<List<Pedido>> listar(String empresaId) async {
    final linhas = await _client
        .from('pedidos')
        .select()
        .eq('empresa_id', empresaId)
        .order('data', ascending: false);
    return linhas.map(Pedido.fromJson).toList();
  }

  /// Obtém o pedido [id] com seus itens, ou `null` se não existir.
  Future<Pedido?> obterComItens(String id) async {
    final linha = await _client
        .from('pedidos')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (linha == null) return null;
    final itens = await _client
        .from('pedidos_itens')
        .select()
        .eq('pedido_id', id);
    return Pedido.fromJson(linha).copyWith(
      itens: itens.map(PedidoItem.fromJson).toList(),
    );
  }

  /// Grava o pedido de forma coesa e retorna-o com os itens.
  ///
  /// Grava a linha `pedidos` e substitui `pedidos_itens` (delete + insert),
  /// preservando os snapshots já definidos em cada item.
  Future<Pedido> salvar(Pedido pedido) async {
    final linha = await _client
        .from('pedidos')
        .upsert(_paraLinha(pedido))
        .select()
        .single();
    final id = linha['id'] as String;

    await _client.from('pedidos_itens').delete().eq('pedido_id', id);
    if (pedido.itens.isNotEmpty) {
      await _client.from('pedidos_itens').insert([
        for (final i in pedido.itens)
          {
            'empresa_id': pedido.empresaId,
            'pedido_id': id,
            'tipo': i.tipo == TipoPedidoItem.produto
                ? 'produto'
                : 'produto_venda',
            'produto_id': i.produtoId,
            'produto_venda_id': i.produtoVendaId,
            'quantidade': i.quantidade,
            'custo_unitario': i.custoUnitario.toString(),
            'abelinhas_unitarias': i.abelinhasUnitarias.toString(),
          },
      ]);
    }

    return (await obterComItens(id))!;
  }

  /// Exclui o pedido [id] (itens caem por cascade).
  Future<void> excluir(String id) async {
    await _client.from('pedidos').delete().eq('id', id);
  }

  Map<String, dynamic> _paraLinha(Pedido p) => {
        if (p.id.isNotEmpty) 'id': p.id,
        'empresa_id': p.empresaId,
        'data': p.data.toIso8601String(),
        'cliente': p.cliente,
        'plataforma_id': p.plataformaId,
        'embalagem': p.embalagem.toString(),
        'impressao': p.impressao.toString(),
        'outros': p.outros.toString(),
        'preco_venda': p.precoVenda.toString(),
        'itens_taxa_fixa': p.itensTaxaFixa,
        'liquido_informado': p.liquidoInformado?.toString(),
        'situacao': _situacao(p.situacao),
        'obs': p.obs,
      };

  String _situacao(SituacaoPedido s) => switch (s) {
        SituacaoPedido.concluido => 'concluido',
        SituacaoPedido.cancelado => 'cancelado',
        SituacaoPedido.devolvido => 'devolvido',
      };
}

/// Provider do [PedidoRepository].
final pedidoRepositoryProvider = Provider<PedidoRepository>((ref) {
  return PedidoRepository(ref.watch(supabaseClientProvider));
});
