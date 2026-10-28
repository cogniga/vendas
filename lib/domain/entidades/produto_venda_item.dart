import 'package:freezed_annotation/freezed_annotation.dart';

part 'produto_venda_item.freezed.dart';
part 'produto_venda_item.g.dart';

/// Item (produto + quantidade) de um produto de venda — tabela
/// `produtos_venda_itens`.
@freezed
class ProdutoVendaItem with _$ProdutoVendaItem {
  const factory ProdutoVendaItem({
    required String id,
    @JsonKey(name: 'empresa_id') required String empresaId,
    @JsonKey(name: 'produto_venda_id') required String produtoVendaId,
    @JsonKey(name: 'produto_id') required String produtoId,
    required int quantidade,
  }) = _ProdutoVendaItem;

  factory ProdutoVendaItem.fromJson(Map<String, dynamic> json) =>
      _$ProdutoVendaItemFromJson(json);
}
